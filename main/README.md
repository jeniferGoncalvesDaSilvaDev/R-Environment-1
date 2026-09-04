# Automação de análise da Série B

Projeto em R para organizar resultados, calcular um modelo estatístico de gols
e simular os possíveis resultados das partidas restantes do campeonato.

O projeto foi pensado para pequenos conjuntos de dados, usando arquivos locais
e uma execução simples pelo Shell do Replit.

## Estrutura

```text
main/
├── README.md
├── main.R
├── run.sh
└── ds-futebol/
    └── ds-futebol/
        ├── config.R
        ├── Script 1 - Organizar dados.R
        ├── Script 2 - Modelo estático.R
        ├── Script 3 - Previsões.R
        ├── Resultados.csv
        ├── Partidas que faltam.csv
        └── resultados/
```

## Como executar

No Shell, a partir da pasta principal do projeto:

```bash
./main/run.sh
```

Também é possível executar diretamente:

```bash
Rscript main/main.R
```

O programa:

1. Entra automaticamente na pasta do projeto;
2. Valida os arquivos de entrada;
3. Organiza os resultados históricos;
4. Calcula os coeficientes do modelo;
5. Simula as partidas restantes;
6. Gera as probabilidades;
7. Salva um log, um resumo e uma cópia datada dos resultados.

## Modo de teste

Para testar a automação rapidamente usando apenas 100 simulações:

```bash
Rscript main/main.R --teste
```

Para escolher a quantidade de simulações:

```bash
Rscript main/main.R --simulacoes 5000
```

O modo normal utiliza a quantidade definida em `config.R`.

## Configuração

As principais configurações ficam em:

```text
main/ds-futebol/ds-futebol/config.R
```

Exemplo:

```r
liga <- "Série B"
ano <- 2025L
numero_de_campeonatos_ficticios <- 1000L
semente <- 2025L
```

### Opções

- `liga`: nome da competição;
- `ano`: ano analisado;
- `numero_de_campeonatos_ficticios`: quantidade de simulações;
- `semente`: permite reproduzir os mesmos resultados usando os mesmos dados.

## Arquivos de entrada

Os principais arquivos usados pela automação são:

```text
Resultados.csv
Partidas que faltam.csv
```

`Resultados.csv` deve conter a coluna:

```text
Em casa / Fora de casa
```

`Partidas que faltam.csv` deve conter as colunas:

```text
Mandante
Visitante
Rodada
```

Para atualizar a análise, substitua esses arquivos pelos dados mais recentes e
execute novamente:

```bash
./main/run.sh
```

## Scripts

### Script 1 - Organizar dados.R

Lê os resultados e transforma os dados em uma tabela organizada de partidas:

```text
Dados Série B.csv
```

### Script 2 - Modelo estático.R

Calcula o modelo de regressão Poisson usando:

- força de ataque;
- força de defesa;
- vantagem de jogar em casa.

Gera:

```text
Coeficientes do modelo.csv
```

### Script 3 - Previsões.R

Usa os coeficientes para simular os campeonatos possíveis e gera:

- placares esperados;
- probabilidades por partida;
- tabela atual;
- probabilidade de cada posição;
- probabilidade de título;
- probabilidade de acesso;
- probabilidade de rebaixamento;
- probabilidade de cada pontuação;
- frequência dos possíveis placares.

## Resultados e logs

Cada execução cria uma pasta datada em:

```text
main/ds-futebol/ds-futebol/resultados/
```

Exemplo:

```text
resultados/
├── logs/
│   └── execucao-2025-09-04_18-30-00.log
├── resumo-2025-09-04_18-30-00.txt
└── 2025-09-04_18-30-00/
    ├── Dados Série B.csv
    ├── Tabela atual.csv
    ├── Previsões por partida.csv
    └── Probabilidades de final de campeonato.csv
```

O resumo contém:

- quantidade de partidas históricas;
- quantidade de partidas pendentes;
- quantidade de simulações;
- arquivos gerados;
- cinco times com maiores probabilidades de título e acesso.

## Pacotes utilizados

O projeto utiliza os componentes necessários do tidyverse diretamente:

```r
dplyr
stringr
tidyr
purrr
data.table
```

Os scripts carregam os componentes individualmente para manter a execução
compatível com o ambiente R do Replit.

## Observações

- Execute os comandos a partir da pasta principal do projeto.
- Não renomeie as colunas exigidas dos arquivos CSV.
- Para testes rápidos, use `--teste`.
- Para resultados mais estáveis, aumente o número de simulações.
- Os resultados são probabilísticos, portanto dependem dos dados de entrada e
  da semente configurada.