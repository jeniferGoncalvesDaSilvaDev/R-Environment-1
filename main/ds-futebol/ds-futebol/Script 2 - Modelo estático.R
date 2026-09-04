source("config.R")
suppressPackageStartupMessages(library(dplyr))

# Leitura dos dados
dados <- read.csv2("Dados Série B.csv", fileEncoding = "latin1", check.names = FALSE)

# Criação das variáveis para modelo
dados_do_mandante <- dados[, c("Time_da_casa", "Time_de_fora_de_casa", "Gols_feitos_pelo_time_da_casa")]
colnames(dados_do_mandante) <- c("Time_no_ataque", "Time_na_defesa", "Gols")
dados_do_mandante$Mandante <- 1
dados_do_visitante <- dados[, c("Time_de_fora_de_casa", "Time_da_casa", "Gols_feitos_pelo_time_de_fora_de_casa")]
colnames(dados_do_visitante) <- c("Time_no_ataque", "Time_na_defesa", "Gols")
dados_do_visitante$Mandante <- 0
dados_para_modelo <- rbind(dados_do_mandante, dados_do_visitante)

# Modelo de regressão Poisson usando times no ataque e na defesa como
# variáveis, assim como fator campo
modelo_estatico <- glm(
  Gols ~ factor(Time_no_ataque) + factor(Time_na_defesa) + Mandante,
  family = poisson,
  data = dados_para_modelo
)

# Organização e salvamento dos coeficientes do modelo
coeficientes_do_modelo <- data.frame(
  Fator = c(
    rep("Ataque", 20),
    rep("Defesa", 20),
    "Intercepto",
    "Mando_de_campo"
  ),
  Time = c(
    unique(dados$Time_da_casa),
    unique(dados$Time_da_casa),
    NA,
    NA
  ),
  Coeficiente = c(
    0,
    coefficients(modelo_estatico)[2 : 20],
    0,
    coefficients(modelo_estatico)[c(21 : 39, 1, 40)]
  ),
  Erro_padrao = c(
    0,
    summary(modelo_estatico)[[12]][2 : 20, 2],
    0,
    summary(modelo_estatico)[[12]][c(21 : 39, 1, 40), 2]
  ),
  Liga = rep(unique(dados$Liga), 42),
  Ano = rep(unique(dados$Ano), 42)
)
coeficientes_do_modelo$Coeficiente[which(
  coeficientes_do_modelo$Fator == "Ataque"
)] <- coeficientes_do_modelo$Coeficiente[which(
  coeficientes_do_modelo$Fator == "Ataque"
)] - mean(coeficientes_do_modelo$Coeficiente[which(
  coeficientes_do_modelo$Fator == "Ataque"
)])
coeficientes_do_modelo$Coeficiente[which(
  coeficientes_do_modelo$Fator == "Defesa"
)] <- coeficientes_do_modelo$Coeficiente[which(
  coeficientes_do_modelo$Fator == "Defesa"
)] - mean(coeficientes_do_modelo$Coeficiente[which(
  coeficientes_do_modelo$Fator == "Defesa"
)])
write.csv2(coeficientes_do_modelo, file = "Coeficientes do modelo.csv", fileEncoding = "latin1")