Proposta do projeto: Automação de análise da Série B
Objetivo
Criar uma automação simples em R para transformar os dados de resultados e partidas futuras em:

Dados organizados
Modelo estatístico de gols
Previsões das partidas
Probabilidades de acesso, título e rebaixamento
Histórico das execuções
Relatórios resumidos
A solução será pensada para pequenos conjuntos de dados, usando arquivos locais e sem banco de dados ou infraestrutura complexa.

Como funcionará
A execução seguirá este fluxo:

Verificar se os arquivos necessários existem
Conferir se as colunas esperadas estão corretas
Organizar os resultados históricos
Calcular os coeficientes de ataque e defesa
Fazer as simulações das partidas restantes
Calcular as probabilidades de cada time
Salvar os resultados
Criar um log da execução
Criar uma cópia dos resultados com data e hora
Exibir um resumo com os principais times
Estrutura proposta
main/
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
            ├── logs/
            ├── resumo-data-hora.txt
            └── data-hora/
                ├── Dados Série B.csv
                ├── Tabela atual.csv
                ├── Previsões por partida.csv
                └── Probabilidades de final de campeonato.csv

Arquivo de configuração
O arquivo config.R concentrará as principais opções:

liga <- "Série B"
ano <- 2025
numero_de_campeonatos_ficticios <- 1000
semente <- 2025

Assim, será possível alterar o ano, a liga ou a quantidade de simulações sem modificar os scripts principais.

Comandos de execução
Execução normal:

./main/run.sh

Ou:

Rscript main/main.R

Execução rápida para testes:

Rscript main/main.R --teste

Esse modo usará poucas simulações para verificar se tudo está funcionando.

Execução com número personalizado de simulações:

Rscript main/main.R --simulacoes 5000

Benefícios
Um único comando para executar todo o projeto
Menor risco de esquecer algum script
Validação automática dos arquivos
Histórico das previsões anteriores
Logs para identificar problemas
Resultados organizados por data
Fácil alteração de configurações
Reprodutibilidade por meio da semente aleatória
Adequado para bases pequenas e análises pessoais
Evoluções futuras
Depois da automação básica, as próximas melhorias poderiam ser:

Atualizar os resultados por meio de um arquivo padrão
Criar um relatório HTML simples
Destacar automaticamente os times com maior chance de acesso
Comparar previsões antigas e novas
Criar gráficos de probabilidades
Adicionar uma verificação de dados duplicados ou incompletos
A ideia central é manter o projeto simples: um comando, arquivos locais, resultados organizados e previsões reproduzíveis.
