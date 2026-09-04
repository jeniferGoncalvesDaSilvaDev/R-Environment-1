source("config.R")
set.seed(semente)

suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(tidyr))
suppressPackageStartupMessages(library(purrr))
suppressPackageStartupMessages(library(data.table))

# Leitura dos dados
dados <- read.csv2("Dados Série B.csv", fileEncoding = "latin1", check.names = FALSE)
coeficientes <- read.csv2("Coeficientes do modelo.csv", fileEncoding = "latin1")
partidas_faltantes <- read.csv2("Partidas que faltam.csv", fileEncoding = "latin1")

# Adição dos valores dos parâmetros de cada time
coeficientes_de_ataque <- coeficientes |>
  filter(Fator == "Ataque") |>
  select(Time, Coeficiente)

coeficientes_de_defesa <- coeficientes |>
  filter(Fator == "Defesa") |>
  select(Time, Coeficiente)

partidas_faltantes_com_fatores_de_ataque_e_defesa <- partidas_faltantes |>
  left_join(
    coeficientes_de_ataque |>
      rename(
        Mandante = Time,
        Fator_de_ataque_do_mandante = Coeficiente
      ),
    by = "Mandante"
  ) |>
  left_join(
    coeficientes_de_ataque |>
      rename(
        Visitante = Time,
        Fator_de_ataque_do_visitante = Coeficiente
      ),
    by = "Visitante"
  ) |>
  left_join(
    coeficientes_de_defesa |>
      rename(
        Mandante = Time,
        Fator_de_defesa_do_mandante = Coeficiente
      ),
    by = "Mandante"
  ) |>
  left_join(
    coeficientes_de_defesa |>
      rename(
        Visitante = Time,
        Fator_de_defesa_do_visitante = Coeficiente
      ),
    by = "Visitante"
  )

# Adição dos valores dos parâmetros Intercepto e Mando de campo
partidas_faltantes_com_fatores_de_ataque_e_defesa$Intercepto <- coeficientes$Coeficiente[which(coeficientes$Fator == "Intercepto")]
partidas_faltantes_com_fatores_de_ataque_e_defesa$Mando_de_campo <- coeficientes$Coeficiente[which(coeficientes$Fator == "Mando_de_campo")]

# Cálculo das médias de gols esperados
partidas_faltantes_com_fatores_de_ataque_e_defesa$Media_esperada_de_gols_do_mandante <- exp(
  partidas_faltantes_com_fatores_de_ataque_e_defesa$Fator_de_ataque_do_mandante +
  partidas_faltantes_com_fatores_de_ataque_e_defesa$Fator_de_defesa_do_visitante +
  partidas_faltantes_com_fatores_de_ataque_e_defesa$Intercepto +
  partidas_faltantes_com_fatores_de_ataque_e_defesa$Mando_de_campo
)
partidas_faltantes_com_fatores_de_ataque_e_defesa$Media_esperada_de_gols_do_visitante <- exp(
  partidas_faltantes_com_fatores_de_ataque_e_defesa$Fator_de_ataque_do_visitante +
  partidas_faltantes_com_fatores_de_ataque_e_defesa$Fator_de_defesa_do_mandante +
  partidas_faltantes_com_fatores_de_ataque_e_defesa$Intercepto
)

# Cálculo e salvamento dos placares esperados de cada partida
placares_esperados <- cbind(
  partidas_faltantes_com_fatores_de_ataque_e_defesa$Rodada,
  partidas_faltantes_com_fatores_de_ataque_e_defesa$Mandante,
  partidas_faltantes_com_fatores_de_ataque_e_defesa$Visitante,
  floor(partidas_faltantes_com_fatores_de_ataque_e_defesa$Media_esperada_de_gols_do_mandante),
  floor(partidas_faltantes_com_fatores_de_ataque_e_defesa$Media_esperada_de_gols_do_visitante)
)
colnames(placares_esperados) <- c(
  "Rodada",
  "Mandante",
  "Visitante",
  "Gols_do_mandante",
  "Gols_do_visitante"
)
write.csv2(placares_esperados, file = "Placares esperados por partida faltante.csv", fileEncoding = "latin1")

# Cálculo e salvamento da tabela atual do Brasileirão
resultados <- dados
resultados$Saldo_de_gols_do_mandante <- resultados$Gols_feitos_pelo_time_da_casa - resultados$Gols_feitos_pelo_time_de_fora_de_casa
resultados$Saldo_de_gols_do_visitante <- resultados$Gols_feitos_pelo_time_de_fora_de_casa - resultados$Gols_feitos_pelo_time_da_casa
resultados$Resultado_do_mandante <- resultados$Saldo_de_gols_do_mandante
resultados$Resultado_do_mandante[which(
  resultados$Resultado_do_mandante > 0
)] <- "Vitória"
resultados$Resultado_do_mandante[which(
  resultados$Resultado_do_mandante == 0
)] <- "Empate"
resultados$Resultado_do_mandante[which(
  resultados$Resultado_do_mandante < 0
)] <- "Derrota"
resultados$Resultado_do_visitante <- resultados$Saldo_de_gols_do_visitante
resultados$Resultado_do_visitante[which(
  resultados$Resultado_do_visitante > 0
)] <- "Vitória"
resultados$Resultado_do_visitante[which(
  resultados$Resultado_do_visitante == 0
)] <- "Empate"
resultados$Resultado_do_visitante[which(
  resultados$Resultado_do_visitante < 0
)] <- "Derrota"
resultados$Pontos_do_mandante <- resultados$Saldo_de_gols_do_mandante
resultados$Pontos_do_mandante[which(
  resultados$Pontos_do_mandante > 0
)] <- 3
resultados$Pontos_do_mandante[which(
  resultados$Pontos_do_mandante == 0
)] <- 1
resultados$Pontos_do_mandante[which(
  resultados$Pontos_do_mandante < 0
)] <- 0
resultados$Pontos_do_visitante <- resultados$Saldo_de_gols_do_visitante
resultados$Pontos_do_visitante[which(
  resultados$Pontos_do_visitante > 0
)] <- 3
resultados$Pontos_do_visitante[which(
  resultados$Pontos_do_visitante == 0
)] <- 1
resultados$Pontos_do_visitante[which(
  resultados$Pontos_do_visitante < 0
)] <- 0
tabela_mandantes <- resultados |>
  group_by(Time_da_casa) |>
  summarise(
    Jogos_mandante    = n(),
    Vitórias_mandante = sum(Resultado_do_mandante == "Vitória", na.rm = TRUE),
    Empates_mandante = sum(Resultado_do_mandante == "Empate", na.rm = TRUE),
    Derrotas_mandante = sum(Resultado_do_mandante == "Derrota", na.rm = TRUE),
    Gols_feitos_mandante = sum(Gols_feitos_pelo_time_da_casa),
    Gols_sofridos_mandante = sum(Gols_feitos_pelo_time_de_fora_de_casa),
    Saldo_de_gols_mandante = sum(Saldo_de_gols_do_mandante),
    Pontos_mandante = sum(Pontos_do_mandante)
  )
tabela_visitantes <- resultados |>
  group_by(Time_de_fora_de_casa) |>
  summarise(
    Jogos_visitante    = n(),
    Vitórias_visitante = sum(Resultado_do_visitante == "Vitória", na.rm = TRUE),
    Empates_visitante = sum(Resultado_do_visitante == "Empate", na.rm = TRUE),
    Derrotas_visitante = sum(Resultado_do_visitante == "Derrota", na.rm = TRUE),
    Gols_feitos_visitante = sum(Gols_feitos_pelo_time_de_fora_de_casa),
    Gols_sofridos_visitante = sum(Gols_feitos_pelo_time_da_casa),
    Saldo_de_gols_visitante = sum(Saldo_de_gols_do_visitante),
    Pontos_visitante = sum(Pontos_do_visitante)
  )
tabela_total <- tabela_mandantes |> 
  merge(
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

# Cálculo dos campeonatos fictícios e dos objetos necessários para previsão
previsoes <- partidas_faltantes_com_fatores_de_ataque_e_defesa
colunas_de_NAs <- matrix(NA, nrow = nrow(previsoes), ncol = numero_de_campeonatos_ficticios)
colnames(colunas_de_NAs) <- paste0("campeonato_", seq_len(numero_de_campeonatos_ficticios))
previsao_de_gols_do_mandante <- cbind(previsoes, colunas_de_NAs)
previsao_de_gols_do_visitante <- cbind(previsoes, colunas_de_NAs)
for(partida_que_falta in c(1 : nrow(previsoes))){
  previsao_de_gols_do_mandante[
    partida_que_falta,
    13 : (numero_de_campeonatos_ficticios + 12)
  ] <- rpois(
    n = numero_de_campeonatos_ficticios,
    lambda = previsao_de_gols_do_mandante$Media_esperada_de_gols_do_mandante[partida_que_falta]
  )
  previsao_de_gols_do_visitante[
    partida_que_falta,
    13 : (numero_de_campeonatos_ficticios + 12)
  ] <- rpois(
    n = numero_de_campeonatos_ficticios,
    lambda = previsao_de_gols_do_visitante$Media_esperada_de_gols_do_visitante[partida_que_falta]
  )
}
previsao_de_saldos_do_mandante <- previsao_de_gols_do_mandante
previsao_de_saldos_do_mandante[
  , 13 : (numero_de_campeonatos_ficticios + 12)
] <- previsao_de_gols_do_mandante[
  , 13 : (numero_de_campeonatos_ficticios + 12)
] - previsao_de_gols_do_visitante[
  , 13 : (numero_de_campeonatos_ficticios + 12)
]
previsao_de_saldos_do_visitante <- previsao_de_gols_do_visitante
previsao_de_saldos_do_visitante[
  , 13 : (numero_de_campeonatos_ficticios + 12)
] <- previsao_de_gols_do_visitante[
  , 13 : (numero_de_campeonatos_ficticios + 12)
] - previsao_de_gols_do_mandante[
  , 13 : (numero_de_campeonatos_ficticios + 12)
]
previsao_de_resultados_do_mandante <- previsao_de_saldos_do_mandante[
  , 13 : (numero_de_campeonatos_ficticios + 12)
]
previsao_de_resultados_do_visitante <- previsao_de_saldos_do_visitante[
  , 13 : (numero_de_campeonatos_ficticios + 12)
]
previsao_de_resultados_do_mandante <- previsao_de_resultados_do_mandante |>
  mutate(across(
    everything(),
    ~ case_when(
      .x > 0  ~ "Vitória",
      .x == 0 ~ "Empate",
      TRUE    ~ "Derrota"
    )
  ))
previsao_de_resultados_do_visitante <- previsao_de_resultados_do_visitante |>
  mutate(across(
    everything(),
    ~ case_when(
      .x > 0  ~ "Vitória",
      .x == 0 ~ "Empate",
      TRUE    ~ "Derrota"
    )
  ))
previsao_de_pontos_do_mandante <- previsao_de_resultados_do_mandante |>
  mutate(across(
    everything(),
    ~ case_when(
      .x == "Vitória" ~ 3,
      .x == "Empate" ~ 1,
      .x == "Derrota" ~ 0
    )
  ))
previsao_de_pontos_do_visitante <- previsao_de_resultados_do_visitante |>
  mutate(across(
    everything(),
    ~ case_when(
      .x == "Vitória" ~ 3,
      .x == "Empate" ~ 1,
      .x == "Derrota" ~ 0
    )
  ))
previsao_de_resultados_do_mandante <- cbind(
  previsao_de_saldos_do_mandante[, c(1 : 12)],
  previsao_de_resultados_do_mandante
)
previsao_de_resultados_do_visitante <- cbind(
  previsao_de_saldos_do_visitante[, c(1 : 12)],
  previsao_de_resultados_do_visitante
)
previsao_de_pontos_do_mandante <- cbind(
  previsao_de_saldos_do_mandante[, c(1 : 12)],
  previsao_de_pontos_do_mandante
)
previsao_de_pontos_do_visitante <- cbind(
  previsao_de_saldos_do_visitante[, c(1 : 12)],
  previsao_de_pontos_do_visitante
)

# Cálculo e salvamento das probabilidades de vitória do mandante
funcao_para_calcular_numero_de_vitorias_do_mandante <- function(x){
  resultados_dos_campeonatos_ficticios <- x[-c(1:12)]
  return(
    sum(
      resultados_dos_campeonatos_ficticios == "Vitória"
    )
  )
}
funcao_para_calcular_numero_de_empates <- function(x){
  resultados_dos_campeonatos_ficticios <- x[-c(1:12)]
  return(
    sum(
      resultados_dos_campeonatos_ficticios == "Empate"
    )
  )
}
funcao_para_calcular_numero_de_vitorias_do_visitante <- function(x){
  resultados_dos_campeonatos_ficticios <- x[-c(1:12)]
  return(
    sum(
      resultados_dos_campeonatos_ficticios == "Derrota"
    )
  )
}
numero_de_vitorias_dos_mandantes <- previsao_de_resultados_do_mandante |> 
  apply(
    FUN = funcao_para_calcular_numero_de_vitorias_do_mandante,
    MARGIN = 1
  )
numero_de_empates <- previsao_de_resultados_do_mandante |> 
  apply(
    FUN = funcao_para_calcular_numero_de_empates,
    MARGIN = 1
  )
numero_de_vitorias_dos_visitantes <- previsao_de_resultados_do_mandante |> 
  apply(
    FUN = funcao_para_calcular_numero_de_vitorias_do_visitante,
    MARGIN = 1
  )
partidas_faltantes_mais_probabilidades <- cbind(
  previsao_de_resultados_do_mandante[, c(2, 1, 3, 4)],
  numero_de_vitorias_dos_mandantes/numero_de_campeonatos_ficticios,
  numero_de_empates/numero_de_campeonatos_ficticios,
  numero_de_vitorias_dos_visitantes/numero_de_campeonatos_ficticios
)
colnames(partidas_faltantes_mais_probabilidades)[5 : 7] <- c(
  "Probabilidade_de_vitória_do_mandante",
  "Probabilidade_de_empate",
  "Probabilidade_de_vitória_do_visitante"
)
write.csv2(partidas_faltantes_mais_probabilidades, file = "Previsões por partida.csv", fileEncoding = "latin1")

# Vamos agora montar os campeonatos fictícios
resultados_ficticios <- list()
for(campeonato in 1:numero_de_campeonatos_ficticios){
  resultados_do_campeonato_ficticio <- cbind(
    previsao_de_gols_do_mandante[, c(2, 12 + campeonato)],
    previsao_de_gols_do_visitante[, c(12 + campeonato, 1)],
    "Brasileirão",
    2025
  )
  colnames(resultados_do_campeonato_ficticio) <- colnames(resultados)[1:6]
  resultados_do_campeonato_ficticio$Saldo_de_gols_do_mandante <- resultados_do_campeonato_ficticio$Gols_feitos_pelo_time_da_casa - resultados_do_campeonato_ficticio$Gols_feitos_pelo_time_de_fora_de_casa
  resultados_do_campeonato_ficticio$Saldo_de_gols_do_visitante <- resultados_do_campeonato_ficticio$Gols_feitos_pelo_time_de_fora_de_casa - resultados_do_campeonato_ficticio$Gols_feitos_pelo_time_da_casa
  resultados_do_campeonato_ficticio$Resultado_do_mandante <- resultados_do_campeonato_ficticio$Saldo_de_gols_do_mandante
  resultados_do_campeonato_ficticio$Resultado_do_mandante[which(
    resultados_do_campeonato_ficticio$Resultado_do_mandante > 0
  )] <- "Vitória"
  resultados_do_campeonato_ficticio$Resultado_do_mandante[which(
    resultados_do_campeonato_ficticio$Resultado_do_mandante == 0
  )] <- "Empate"
  resultados_do_campeonato_ficticio$Resultado_do_mandante[which(
    resultados_do_campeonato_ficticio$Resultado_do_mandante < 0
  )] <- "Derrota"
  resultados_do_campeonato_ficticio$Resultado_do_visitante <- resultados_do_campeonato_ficticio$Saldo_de_gols_do_visitante
  resultados_do_campeonato_ficticio$Resultado_do_visitante[which(
    resultados_do_campeonato_ficticio$Resultado_do_visitante > 0
  )] <- "Vitória"
  resultados_do_campeonato_ficticio$Resultado_do_visitante[which(
    resultados_do_campeonato_ficticio$Resultado_do_visitante == 0
  )] <- "Empate"
  resultados_do_campeonato_ficticio$Resultado_do_visitante[which(
    resultados_do_campeonato_ficticio$Resultado_do_visitante < 0
  )] <- "Derrota"
  resultados_do_campeonato_ficticio$Pontos_do_mandante <- resultados_do_campeonato_ficticio$Saldo_de_gols_do_mandante
  resultados_do_campeonato_ficticio$Pontos_do_mandante[which(
    resultados_do_campeonato_ficticio$Pontos_do_mandante > 0
  )] <- 3
  resultados_do_campeonato_ficticio$Pontos_do_mandante[which(
    resultados_do_campeonato_ficticio$Pontos_do_mandante == 0
  )] <- 1
  resultados_do_campeonato_ficticio$Pontos_do_mandante[which(
    resultados_do_campeonato_ficticio$Pontos_do_mandante < 0
  )] <- 0
  resultados_do_campeonato_ficticio$Pontos_do_visitante <- resultados_do_campeonato_ficticio$Saldo_de_gols_do_visitante
  resultados_do_campeonato_ficticio$Pontos_do_visitante[which(
    resultados_do_campeonato_ficticio$Pontos_do_visitante > 0
  )] <- 3
  resultados_do_campeonato_ficticio$Pontos_do_visitante[which(
    resultados_do_campeonato_ficticio$Pontos_do_visitante == 0
  )] <- 1
  resultados_do_campeonato_ficticio$Pontos_do_visitante[which(
    resultados_do_campeonato_ficticio$Pontos_do_visitante < 0
  )] <- 0
  resultados_do_campeonato_ficticio <- rbind(
    resultados,
    resultados_do_campeonato_ficticio
  )
  resultados_ficticios[[campeonato]] <- resultados_do_campeonato_ficticio
}

# E agora vamos montar as tabelas de cada campeonato fictício
tabelas_ficticias <- list()
for(campeonato in 1:numero_de_campeonatos_ficticios){
  resultados_do_campeonato_ficticio <- resultados_ficticios[[campeonato]]
  tabela_mandantes <- resultados_do_campeonato_ficticio |>
    group_by(Time_da_casa) |>
    summarise(
      Jogos_mandante    = n(),
      Vitórias_mandante = sum(Resultado_do_mandante == "Vitória", na.rm = TRUE),
      Empates_mandante = sum(Resultado_do_mandante == "Empate", na.rm = TRUE),
      Derrotas_mandante = sum(Resultado_do_mandante == "Derrota", na.rm = TRUE),
      Gols_feitos_mandante = sum(Gols_feitos_pelo_time_da_casa),
      Gols_sofridos_mandante = sum(Gols_feitos_pelo_time_de_fora_de_casa),
      Saldo_de_gols_mandante = sum(Saldo_de_gols_do_mandante),
      Pontos_mandante = sum(Pontos_do_mandante)
    )
  tabela_visitantes <- resultados_do_campeonato_ficticio |>
    group_by(Time_de_fora_de_casa) |>
    summarise(
      Jogos_visitante    = n(),
      Vitórias_visitante = sum(Resultado_do_visitante == "Vitória", na.rm = TRUE),
      Empates_visitante = sum(Resultado_do_visitante == "Empate", na.rm = TRUE),
      Derrotas_visitante = sum(Resultado_do_visitante == "Derrota", na.rm = TRUE),
      Gols_feitos_visitante = sum(Gols_feitos_pelo_time_de_fora_de_casa),
      Gols_sofridos_visitante = sum(Gols_feitos_pelo_time_da_casa),
      Saldo_de_gols_visitante = sum(Saldo_de_gols_do_visitante),
      Pontos_visitante = sum(Pontos_do_visitante)
    )
  tabela_total <- tabela_mandantes |> 
    merge(
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
  tabelas_ficticias[[campeonato]] <- tabela_total
}

# Para finalizar, vamos calcular as posições finais de cada time
# Esses são os critérios de desempate, segundo a Wikipedia:
## Em caso de empate por pontos entre dois clubes, os critérios de desempate foram aplicados na seguinte ordem:[29]
## 
## Número de vitórias;
## Saldo de gols;
## Gols pró (marcados);
## Confronto direto;
## Menor número de cartões vermelhos;
## Menor número de cartões amarelos;
## Sorteio.
tabelas_ficticias_ordenadas_v1 <- tabelas_ficticias
for(campeonato in 1:numero_de_campeonatos_ficticios){
  tabela_atual <- tabelas_ficticias_ordenadas_v1[[campeonato]]
  tabela_ordenada <- tabela_atual |> 
    arrange(
      desc(Pontos),
      desc(Vitórias),
      desc(Saldo_de_gols),
      desc(Gols_feitos)
    )
  tabela_ordenada$Posicao_final <- c(1 : 20)
  tabelas_ficticias_ordenadas_v1[[campeonato]] <- tabela_ordenada
}

# Agora vamos calcular a quantidade de campeonatos fictícios em que cada
#time terminou em cada posição
campeonatos_colapsados <- do.call(
  rbind,
  tabelas_ficticias_ordenadas_v1
)
write.csv2(
  table(
    campeonatos_colapsados$Time_da_casa,
    campeonatos_colapsados$Posicao_final
  ) / numero_de_campeonatos_ficticios,
  file = "Probabilidades de cada time terminar em cada posição.csv",
  fileEncoding = "latin1"
)

# Com isso feito, vamos adicionar agora as probabilidades de libertadores
probabilidades_de_cada_time_em_cada_posicao <- read.csv2(
  file = "Probabilidades de cada time terminar em cada posição.csv",
  fileEncoding = "latin1"
)
colnames(probabilidades_de_cada_time_em_cada_posicao) <- c(
  "Time",
  c(1 : 20)
)
probabilidades_de_cada_time_em_cada_posicao$Titulo <- probabilidades_de_cada_time_em_cada_posicao$`1`
probabilidades_de_cada_time_em_cada_posicao$Acesso <- probabilidades_de_cada_time_em_cada_posicao$`1` +
  probabilidades_de_cada_time_em_cada_posicao$`2` +
  probabilidades_de_cada_time_em_cada_posicao$`3` +
  probabilidades_de_cada_time_em_cada_posicao$`4`
probabilidades_de_cada_time_em_cada_posicao$Rebaixamento <- probabilidades_de_cada_time_em_cada_posicao$`17` +
  probabilidades_de_cada_time_em_cada_posicao$`18` +
  probabilidades_de_cada_time_em_cada_posicao$`19` +
  probabilidades_de_cada_time_em_cada_posicao$`20`
write.csv2(
  probabilidades_de_cada_time_em_cada_posicao,
  file = "Probabilidades de final de campeonato.csv",
  fileEncoding = "latin1"
)

# E Agora vamos calcular a quantidade de campeonatos fictícios em que cada
#time terminou com cada pontuação
write.csv2(
  table(
    campeonatos_colapsados$Time_da_casa,
    campeonatos_colapsados$Pontos
  ) / numero_de_campeonatos_ficticios,
  file = "Probabilidades de cada time terminar em cada pontuação.csv",
  fileEncoding = "latin1"
)

# Finalmente, vamos calcular para cada partida quais são os possíveis
#placares, e suas probabilidades

# Função para transformar os data frames
transforma_dfs_de_gols <- function(df, nova_coluna) {
  df %>%
    pivot_longer(cols = 13:(numero_de_campeonatos_ficticios + 12), names_to = "simulacao", values_to = nova_coluna) %>%
    select(1:12, all_of(nova_coluna))
}

# Aplica transformação
gols_de_mandantes_em_formato_longo <- transforma_dfs_de_gols(previsao_de_gols_do_mandante, "gols_mandante")
gols_de_visitantes_em_formato_longo <- transforma_dfs_de_gols(previsao_de_gols_do_visitante, "gols_visitante")

# Junta os dois data frames pelas 12 colunas compartilhadas
placares_ficticios_de_cada_partida <- bind_cols(
  gols_de_mandantes_em_formato_longo %>% arrange(Mandante, Visitante),
  gols_de_visitantes_em_formato_longo %>% arrange(Mandante, Visitante) %>% select(gols_visitante)
)

# Agora precisamos definir quantos gols é "possível" que um time faça
gols_possiveis <- 0:10

# Depois calcular para cada partida as frequências de cada placar
funcao_para_calcular_frequencia_de_placar_por_partida <- function(i) {
  inicio <- (i - 1) * numero_de_campeonatos_ficticios + 1
  fim <- i * numero_de_campeonatos_ficticios
  
  frequencia_de_placares_da_partida <- placares_ficticios_de_cada_partida[inicio:fim, ]
  
  tabela_de_frequencia_dos_placares <- table(
    factor(frequencia_de_placares_da_partida$gols_mandante, levels = gols_possiveis),
    factor(frequencia_de_placares_da_partida$gols_visitante, levels = gols_possiveis)
  )
  
  as.data.frame(tabela_de_frequencia_dos_placares) %>%
    rename(
      gols_mandante = Var1,
      gols_visitante = Var2,
      frequencia = Freq
    ) %>%
    mutate(
      gols_mandante = as.integer(as.character(gols_mandante)),
      gols_visitante = as.integer(as.character(gols_visitante)),
      Mandante = frequencia_de_placares_da_partida$Mandante[1],
      Visitante = frequencia_de_placares_da_partida$Visitante[1],
      Data = frequencia_de_placares_da_partida$Data[1],
      Rodada = frequencia_de_placares_da_partida$Rodada[1]
    )
}

# Finalmente, vamos juntar todas as frequências de placar num só arquivo
frequencia_de_placares_para_todas_as_partidas <- map_dfr(1 : nrow(partidas_faltantes), funcao_para_calcular_frequencia_de_placar_por_partida)
write.csv2(
  frequencia_de_placares_para_todas_as_partidas,
  file = "Frequências de placares para cada partida.csv",
  fileEncoding = "latin1",
  row.names = F
)