args <- commandArgs(trailingOnly = TRUE)
raw_args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", raw_args, value = TRUE)

if (length(file_arg) == 0) {
  stop("Execute este arquivo com: Rscript main/main.R")
}

main_file <- normalizePath(sub("^--file=", "", file_arg[[1]]))
main_dir <- dirname(main_file)
project_dir <- file.path(main_dir, "ds-futebol", "ds-futebol")
presentation_file <- file.path(main_dir, "mostrar-previsoes.R")

if (!dir.exists(project_dir)) {
  stop("Pasta do projeto não encontrada: ", project_dir)
}

if (!file.exists(presentation_file)) {
  stop("Arquivo de apresentação das previsões não encontrado: ", presentation_file)
}

setwd(project_dir)
source("config.R")
source(presentation_file)

if ("--teste" %in% args) {
  numero_de_campeonatos_ficticios <- 100L
}

if ("--simulacoes" %in% args) {
  index <- match("--simulacoes", args)
  if (is.na(index) || index == length(args)) {
    stop("Use --simulacoes acompanhado de um número inteiro.")
  }

  simulacoes <- suppressWarnings(as.integer(args[[index + 1L]]))
  if (is.na(simulacoes) || simulacoes < 1L) {
    stop("O número de simulações deve ser um inteiro maior que zero.")
  }

  numero_de_campeonatos_ficticios <- simulacoes
}

stamp <- format(Sys.time(), "%Y-%m-%d_%H-%M-%S")
results_dir <- file.path(project_dir, "resultados")
log_dir <- file.path(results_dir, "logs")
snapshot_dir <- file.path(results_dir, stamp)
dir.create(log_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(snapshot_dir, recursive = TRUE, showWarnings = FALSE)

log_file <- file.path(log_dir, paste0("execucao-", stamp, ".log"))
log_connection <- file(log_file, open = "wt", encoding = "UTF-8")
sink(log_connection, split = TRUE)
sink(log_connection, type = "message", append = TRUE)
on.exit({
  sink(type = "message")
  sink()
  close(log_connection)
}, add = TRUE)

cat("Automação do projeto ds-futebol\n")
cat("Início: ", format(Sys.time()), "\n", sep = "")
cat("Liga: ", liga, " | Ano: ", ano, "\n", sep = "")
cat("Simulações: ", numero_de_campeonatos_ficticios, "\n\n", sep = "")

required_inputs <- c("Resultados.csv", "Partidas que faltam.csv")
missing_inputs <- required_inputs[!file.exists(required_inputs)]
if (length(missing_inputs) > 0L) {
  stop("Arquivos de entrada ausentes: ", paste(missing_inputs, collapse = ", "))
}

resultados <- read.csv2(
  "Resultados.csv",
  fileEncoding = "latin1",
  check.names = FALSE
)
partidas_faltantes <- read.csv2(
  "Partidas que faltam.csv",
  fileEncoding = "latin1",
  check.names = FALSE
)

required_resultados_columns <- "Em casa / Fora de casa"
required_partidas_columns <- c("Mandante", "Visitante", "Rodada")

if (!required_resultados_columns %in% names(resultados)) {
  stop("Resultados.csv não possui a coluna 'Em casa / Fora de casa'.")
}

missing_partidas_columns <- setdiff(
  required_partidas_columns,
  names(partidas_faltantes)
)
if (length(missing_partidas_columns) > 0L) {
  stop(
    "Partidas que faltam.csv não possui: ",
    paste(missing_partidas_columns, collapse = ", ")
  )
}

cat("Validação concluída: ", nrow(resultados), " linhas em Resultados.csv e ",
    nrow(partidas_faltantes), " partidas pendentes.\n\n", sep = "")

run_step <- function(script_file, expected_file = NULL) {
  cat("Executando ", script_file, "...\n", sep = "")
  source(script_file, echo = FALSE)

  if (!is.null(expected_file) && !file.exists(expected_file)) {
    stop("O script terminou, mas não gerou: ", expected_file)
  }

  cat("Concluído: ", script_file, "\n\n", sep = "")
}

run_step("Script 1 - Organizar dados.R", "Dados Série B.csv")
run_step("Script 2 - Modelo estático.R", "Coeficientes do modelo.csv")
run_step("Script 3 - Previsões.R", "Probabilidades de final de campeonato.csv")

output_files <- c(
  "Dados Série B.csv",
  "Coeficientes do modelo.csv",
  "Placares esperados por partida faltante.csv",
  "Tabela atual.csv",
  "Previsões por partida.csv",
  "Probabilidades de cada time terminar em cada posição.csv",
  "Probabilidades de final de campeonato.csv",
  "Probabilidades de cada time terminar em cada pontuação.csv",
  "Frequências de placares para cada partida.csv"
)
output_files <- output_files[file.exists(output_files)]
file.copy(output_files, snapshot_dir, overwrite = TRUE)

summary_lines <- c(
  "Resumo da execução",
  paste0("Data: ", format(Sys.time())),
  paste0("Liga: ", liga),
  paste0("Ano: ", ano),
  paste0("Simulações: ", numero_de_campeonatos_ficticios),
  paste0("Partidas históricas: ", nrow(resultados)),
  paste0("Partidas pendentes: ", nrow(partidas_faltantes)),
  paste0("Arquivos gerados: ", length(output_files))
)

probabilidades_file <- "Probabilidades de final de campeonato.csv"
if (file.exists(probabilidades_file)) {
  probabilidades <- read.csv2(
    probabilidades_file,
    fileEncoding = "latin1",
    check.names = FALSE
  )

  if (all(c("Time", "Titulo", "Acesso", "Rebaixamento") %in% names(probabilidades))) {
    melhores <- probabilidades[
      order(-probabilidades$Titulo, -probabilidades$Acesso),
      c("Time", "Titulo", "Acesso", "Rebaixamento")
    ]
    melhores <- head(melhores, 5L)
    summary_lines <- c(
      summary_lines,
      "",
      "Top 5 probabilidades:",
      paste(
        apply(melhores, 1, function(row) {
          paste0(
            row[["Time"]],
            " | título: ", row[["Titulo"]],
            " | acesso: ", row[["Acesso"]],
            " | rebaixamento: ", row[["Rebaixamento"]]
          )
        }),
        collapse = "\n"
      )
    )
  }
}

summary_file <- file.path(results_dir, paste0("resumo-", stamp, ".txt"))
writeLines(summary_lines, summary_file, useBytes = TRUE)
file.copy(summary_file, snapshot_dir, overwrite = TRUE)

cat("\nAutomação concluída com sucesso.\n")
cat("Resultados desta execução: ", snapshot_dir, "\n", sep = "")
cat("Log: ", log_file, "\n", sep = "")
cat("Resumo: ", summary_file, "\n", sep = "")
mostrar_previsoes(project_dir)