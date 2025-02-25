#!/usr/bin/env pwsh

$ErrorActionPreference = 'Stop'

$BinDir = "$Home\.rango-printer"
$ExePath = "$BinDir\rango-printer.exe"


# Criar diretório se não existir
if (!(Test-Path $BinDir)) {
    New-Item $BinDir -ItemType Directory | Out-Null
}

# Copiar executável atual para o diretório bin
# Criar diretório tmp se não existir
$TmpDir = "$BinDir\tmp"
if (!(Test-Path $TmpDir)) {
    New-Item $TmpDir -ItemType Directory | Out-Null
}
Copy-Item ".\pedidos_impressos.txt" -Destination $BinDir -Force
Copy-Item ".\PDFtoPrinter.exe" -Destination $BinDir -Force
Copy-Item ".\rango-printer.exe" -Destination $ExePath -Force

# Adicionar ao PATH do usuário
$User = [EnvironmentVariableTarget]::User
$Path = [Environment]::GetEnvironmentVariable('Path', $User)
if (!(";$Path;".ToLower() -like "*;$BinDir;*".ToLower())) {
    [Environment]::SetEnvironmentVariable('Path', "$Path;$BinDir", $User)
    $Env:Path += ";$BinDir"
}


Write-Output "Rango Printer CLI instalado com sucesso em $ExePath"
Write-Output "Execute 'rango-printer --help' para começar"