param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]] $Argumentos
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot

$rscriptCommand = Get-Command Rscript -ErrorAction SilentlyContinue
if ($null -ne $rscriptCommand) {
    $rscript = $rscriptCommand.Source
} else {
    $candidates = @(
        (Get-ChildItem "$env:ProgramFiles\R\*\bin\Rscript.exe" -ErrorAction SilentlyContinue),
        (Get-ChildItem "${env:ProgramFiles(x86)}\R\*\bin\Rscript.exe" -ErrorAction SilentlyContinue),
        (Get-ChildItem "$env:LOCALAPPDATA\Programs\R\*\bin\Rscript.exe" -ErrorAction SilentlyContinue)
    ) | Where-Object { $null -ne $_ } | Sort-Object FullName -Descending

    if ($candidates.Count -eq 0) {
        throw "Rscript não foi encontrado. Instale o R pelo site https://cran.r-project.org/ e abra um novo terminal."
    }

    $rscript = $candidates[0].FullName
}

$packages = @("dplyr", "stringr", "tidyr", "purrr", "data.table")
$missingPackages = & $rscript -e "cat(paste(setdiff(c('$($packages -join "','")'), rownames(installed.packages())), collapse=' '))"
if ($missingPackages) {
    Write-Host "Instalando pacotes R ausentes: $missingPackages"
    & $rscript -e "install.packages(c('$($missingPackages.Trim() -replace ' ', ''',''')'), repos='https://cloud.r-project.org')"
    if ($LASTEXITCODE -ne 0) {
        throw "Não foi possível instalar os pacotes R necessários."
    }
}

Set-Location $projectRoot
& $rscript (Join-Path $PSScriptRoot "main.R") @Argumentos
exit $LASTEXITCODE
