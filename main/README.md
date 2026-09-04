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

### Windows PowerShell — passo a passo

Use esta seção se estiver executando o projeto pelo PowerShell ou pelo terminal
integrado do VS Code.

#### 1. Abra o PowerShell

No VS Code, abra **Terminal > Novo Terminal** ou pressione `Ctrl + ``.

#### 2. Entre na pasta `main`

Abra o terminal na pasta raiz do repositório clonado. Não use um caminho
absoluto: o nome da unidade e a pasta do projeto podem ser diferentes em cada
computador.

```powershell
cd ".\main"
```

Se o terminal já estiver dentro da pasta `main`, não execute o `cd` novamente.

#### 3. Verifique o R

O Windows normalmente adiciona o R ao `PATH`. Confira com:

```powershell
Get-Command Rscript
Rscript --version
```

Se `Rscript` não for encontrado, instale o R pelo site oficial:
[CRAN](https://cran.r-project.org/bin/windows/base/). Depois, feche e abra o
terminal novamente.

#### 4. Configure o caminho do R somente se necessário

Use este comando apenas quando `Rscript --version` não funcionar. Ele procura
automaticamente instalações do R nas pastas padrão do Windows, sem depender da
versão instalada ou do nome do usuário:

```powershell
$rCandidates = @(
    (Get-ChildItem "$env:ProgramFiles\R\*\bin\Rscript.exe" -ErrorAction SilentlyContinue),
    (Get-ChildItem "${env:ProgramFiles(x86)}\R\*\bin\Rscript.exe" -ErrorAction SilentlyContinue),
    (Get-ChildItem "$env:LOCALAPPDATA\Programs\R\*\bin\Rscript.exe" -ErrorAction SilentlyContinue)
) | Where-Object { $null -ne $_ } | Sort-Object FullName -Descending

if ($rCandidates.Count -eq 0) {
    Write-Error "R não encontrado. Instale-o pelo site https://cran.r-project.org/"
} else {
    $env:Path += ";" + $rCandidates[0].Directory.FullName
}

Rscript --version
```

#### 5. Execute a automação completa (recomendado)

Este arquivo encontra o `Rscript` automaticamente, instala os pacotes ausentes
na biblioteca do usuário e executa os três scripts na ordem correta:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\executar-automacao.ps1
```

A automação:

1. Entra automaticamente na pasta do projeto;
2. Valida os arquivos de entrada;
3. Organiza os resultados históricos;
4. Calcula os coeficientes do modelo;
5. Simula as partidas restantes;
6. Gera as probabilidades;
7. Salva um log, um resumo e uma cópia datada dos resultados.

Ao final, o terminal também exibe as previsões detalhadas de cada partida
pendente, incluindo o placar esperado e as probabilidades de vitória, empate e
derrota. Em seguida, mostra o top 10 da classificação projetada.

#### 6. Execute somente o script de previsões

O arquivo `Script 3 - Previsões.R` depende de `config.R` e, por isso, deve ser
executado a partir da pasta `main\ds-futebol\ds-futebol`:

```powershell
Push-Location ".\ds-futebol\ds-futebol"
Rscript ".\Script 3 - Previsões.R"
Pop-Location
```

#### 7. Execute uma versão rápida para teste

Para testar rapidamente usando apenas 100 simulações:

```powershell
.\executar-automacao.ps1 --teste
```

Para escolher outra quantidade de simulações:

```powershell
.\executar-automacao.ps1 --simulacoes 5000
```

Os comandos `--teste` e `--simulacoes` exibem a mesma saída detalhada no
terminal; somente a quantidade de simulações muda.

#### 8. Localize os resultados

Os resultados ficam nesta pasta:

```text
main\ds-futebol\ds-futebol\resultados\
```

Cada execução cria uma pasta com data e hora, além de um arquivo de log e um
resumo.

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