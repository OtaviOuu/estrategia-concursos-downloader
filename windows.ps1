# setup.ps1
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "🔧 Iniciando setup do projeto..."

try {
    $pythonVersion = & python --version 2>&1
    if ($pythonVersion -notmatch 'Python 3\.(1[0-9]|[2-9][0-9])') {
        throw "Versão do Python insuficiente."
    }
} catch {
    Write-Host "⚠️ Python 3.10+ não encontrado. Instale Python 3.10 ou superior." -ForegroundColor Red
    exit 1
}

function Is-CommandAvailable($cmd) {
    $null -ne (Get-Command $cmd -ErrorAction SilentlyContinue)
}

if (-not (Is-CommandAvailable "uv")) {
    Write-Host "⏬ Instalando uv..."
    Invoke-WebRequest -UseBasicParsing https://astral.sh/uv/install.ps1 -OutFile "$env:TEMP\uv_install.ps1"
    & powershell -ExecutionPolicy Bypass -File "$env:TEMP\uv_install.ps1"
    
    $env:PATH += ";$env:USERPROFILE\.cargo\bin"
}

Write-Host "📦 Instalando dependências com uv..."
& uv sync

$mainPath = Join-Path -Path (Get-Location) -ChildPath "src\main.py"
if (Test-Path $mainPath) {
    Write-Host "🚀 Rodando main.py"
    & python $mainPath
} else {
    Write-Host "⚠️ main.py não encontrado." -ForegroundColor Yellow
}
