# Automação e simulação de campeonatos brasileiros

Projeto em R para organizar resultados, calcular um modelo estatístico de gols
e simular os possíveis resultados das partidas restantes do campeonato.

O projeto foi pensado para pequenos conjuntos de dados, usando arquivos locais
e uma execução simples pelo Shell do Replit.

## Como o modelo funciona

O modelo usa os placares já realizados para estimar, para cada equipe, uma
força de ataque e uma força de defesa. Ele também estima a vantagem de jogar em
casa por meio de uma regressão de Poisson:

1. Para cada partida, combina o ataque de uma equipe com a defesa do adversário.
2. Acrescenta o efeito de mando de campo para estimar os gols esperados do
   mandante. Para o visitante, não acrescenta esse efeito.
3. Sorteia placares possíveis de acordo com essas médias e repete o processo
   para a quantidade de campeonatos simulados.
4. Em cada campeonato simulado, soma os resultados já disputados e os
   simulados, ordenando os times por pontos, vitórias, saldo de gols e gols
   marcados.
5. Calcula as probabilidades contando em quantas simulações cada resultado ou
   posição aconteceu.

As partidas futuras são simuladas com placares aleatórios segundo as médias
estimadas. Por isso, as probabilidades são estimativas estatísticas: não são
previsões certas nem garantias.

## Estrutura

```text
main/
├── README.md
├── main.R
├── executar-automacao.ps1
├── mostrar-previsoes.R
├── serie-a-2026/
│   ├── config.R
│   ├── FONTE.txt
│   ├── Resultados.csv
│   ├── Partidas que faltam.csv
│   └── calendario-ogol-2026.csv
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

### Windows PowerShell

Os comandos não dependem do nome de usuário, da unidade ou da pasta onde o
repositório foi clonado. Abra o terminal na raiz do repositório.

#### 1. Entre na pasta `main`

```powershell
cd ".\main"
```

#### 2. Execute a Série B 2025

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\executar-automacao.ps1 --teste
```

Para usar 5.000 simulações, por exemplo:

```powershell
.\executar-automacao.ps1 --simulacoes 5000
```

#### 3. Execute a Série A 2026

Este conjunto é separado dos dados da Série B:

```powershell
.\executar-automacao.ps1 --projeto "serie-a-2026" --simulacoes 5000
```

`--teste` sempre usa 100 simulações. Se preferir, também pode rodar a Série A
no modo rápido:

```powershell
.\executar-automacao.ps1 --projeto "serie-a-2026" --teste
```

O script PowerShell localiza o R, instala pacotes necessários que estiverem
faltando e preserva a pasta atual do terminal. O computador precisa ter R
instalado e acesso à internet para a instalação inicial dos pacotes.

### macOS e Linux

Instale o R para seu sistema operacional e confirme que `Rscript` está
disponível no terminal:

```sh
Rscript --version
```

Se os pacotes ainda não estiverem instalados, instale-os uma vez:

```sh
Rscript -e 'install.packages(c("dplyr", "stringr", "tidyr", "purrr", "data.table"), repos="https://cloud.r-project.org")'
```

Na raiz do repositório, entre em `main` e execute a Série A:

```sh
cd ./main
Rscript main.R --projeto "serie-a-2026" --simulacoes 5000
```

Para executar 100 simulações:

```sh
Rscript main.R --projeto "serie-a-2026" --teste
```

Para executar a Série B padrão, omita `--projeto`:

```sh
Rscript main.R --teste
```

Os comandos acima usam caminhos relativos ao repositório; não é necessário
editar caminhos com nome de usuário, unidade ou versão específica do R.

### Como ler a saída no terminal

Ao final da execução, o terminal apresenta as previsões detalhadas das partidas
pendentes. Para cada jogo, mostra a rodada, os times, o placar estimado e as
probabilidades de vitória do mandante, empate e vitória do visitante. Essas
probabilidades são calculadas a partir da frequência de cada resultado nas
simulações.

O “placar esperado” é uma estimativa de gols produzida pelas médias do modelo;
não é um placar confirmado nem necessariamente o resultado mais provável.
Depois das partidas, aparece a classificação projetada dos dez primeiros:

- **Título:** proporção de simulações em que o time terminou em 1º lugar;
- **G4:** proporção de simulações em que terminou entre os quatro primeiros;
- **Rebaixamento:** proporção de simulações em que terminou entre o 17º e o
  20º lugar.

Por exemplo, `Título: 20%` significa que o time foi campeão em 20% das
simulações executadas. Para a Série B, a coluna correspondente ao G4 é
apresentada como **Acesso**.

### Fonte e ressalva dos dados — Brasileirão Série A 2026

Fontes consultadas em 23/10/2026:

- [Estatísticas da edição no oGol](https://www.ogol.com.br/edicao/brasileirao-serie-a-2026/210277/estatisticas)
- [Calendário da edição no oGol](https://www.ogol.com.br/edicao/brasileirao-serie-a-2026/210277/calendario)

Foram coletados 360 jogos publicados no calendário: 309 com placar e 51 sem
resultado final. O total de 309 jogos foi conferido com o resumo de estatísticas
da página. As partidas sem resultado permanecem como pendentes.

Na data da consulta, o calendário não listava as rodadas 35 e 38. Para completar
os 380 jogos previstos para 20 equipes em turno e returno, os 10 confrontos da
rodada 35 foram inferidos como o returno invertido da rodada 16; os 10 da
rodada 38 foram inferidos como o returno invertido da rodada 19. O padrão foi
conferido nas demais rodadas de ida e volta disponíveis. As datas desses 20
jogos aparecem como “A definir”. Esses confrontos são inferências, não jogos
publicados pelo oGol.

Os resultados e as previsões são estimativas estatísticas, não garantias.
Consulte `serie-a-2026/FONTE.txt` e `serie-a-2026/calendario-ogol-2026.csv`
para a origem e a marcação de cada partida.

### Onde ficam os resultados

Os arquivos gerados ficam na pasta `resultados` do conjunto executado:

```text
main\serie-a-2026\resultados\
main\ds-futebol\ds-futebol\resultados\
```

Cada execução cria uma pasta com data e hora, além de um arquivo de log e um
resumo. A pasta da execução contém, entre outros arquivos, os placares
esperados, as probabilidades por partida e a classificação final simulada.

O programa:

1. Entra automaticamente na pasta do projeto;
2. Valida os arquivos de entrada;
3. Organiza os resultados históricos;
4. Calcula os coeficientes do modelo;
5. Simula as partidas restantes;
6. Gera as probabilidades;
7. Salva um log, um resumo e uma cópia datada dos resultados.

## Configuração

As configurações ficam separadas por conjunto de dados:

```text
main/ds-futebol/ds-futebol/config.R
main/serie-a-2026/config.R
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
- probabilidade de G4 (Série A) ou acesso (Série B);
- probabilidade de rebaixamento;
- probabilidade de cada pontuação;
- frequência dos possíveis placares.

## Resultados e logs

Cada execução cria uma pasta datada em:

```text
main/<conjunto-de-dados>/resultados/
```

Por exemplo, a Série A grava em `main/serie-a-2026/resultados/` e a Série B
em `main/ds-futebol/ds-futebol/resultados/`.

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
- cinco times com maiores probabilidades de título e G4/acesso.

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

- Os comandos de execução usam caminhos relativos; não precisam de caminhos
  absolutos com usuário, unidade ou versão específica do R.
- No Windows, use `executar-automacao.ps1`; no macOS/Linux, use `Rscript main.R`
  conforme os exemplos acima.
- Não renomeie as colunas exigidas dos arquivos CSV.
- Para testes rápidos, use `--teste`.
- Para resultados mais estáveis, aumente o número de simulações.
- Os resultados são probabilísticos, portanto dependem dos dados de entrada e
  da semente configurada.