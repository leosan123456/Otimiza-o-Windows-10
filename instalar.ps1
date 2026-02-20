# ============================================================
# INSTALADOR / BOOTSTRAPPER - Otimizador Windows 10
# Como usar (cole no PowerShell):
#
#   irm bit.ly/otimizadorwin10 | iex
# ou diretamente:
#   irm 'https://raw.githubusercontent.com/leosan123456/Otimiza-o-Windows-10/main/instalar.ps1' | iex
#
# ============================================================

$ErrorActionPreference = 'Stop'
$ProgressPreference    = 'SilentlyContinue'   # irm mais rapido sem barra de progresso

# ============================================================
# CABECALHO
# ============================================================
Write-Host ""
Write-Host "  ==========================================" -ForegroundColor Cyan
Write-Host "    OTIMIZADOR WINDOWS 10  |  Instalador   " -ForegroundColor Cyan
Write-Host "  ==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Repositorio: github.com/leosan123456/Otimiza-o-Windows-10" -ForegroundColor DarkGray
Write-Host ""

# ============================================================
# VERIFICAR COMPATIBILIDADE
# ============================================================
$psVer = $PSVersionTable.PSVersion.Major
if ($psVer -lt 5) {
    Write-Host "  [ERRO] PowerShell 5.1 ou superior necessario. Versao atual: $psVer" -ForegroundColor Red
    Write-Host "  Atualize o PowerShell em: https://aka.ms/wmf5download" -ForegroundColor Yellow
    exit 1
}

$osVer = [System.Environment]::OSVersion.Version
if ($osVer.Major -lt 10) {
    Write-Host "  [AVISO] Este script foi criado para Windows 10. Use com cuidado em versoes anteriores." -ForegroundColor Yellow
}

# ============================================================
# DEFINIR DESTINO DE INSTALACAO
# ============================================================
$destDir = Join-Path $env:LOCALAPPDATA "OtimizadorWindows10"

Write-Host "  Pasta de instalacao:" -ForegroundColor Gray
Write-Host "  $destDir" -ForegroundColor White
Write-Host ""

try {
    New-Item -ItemType Directory -Force -Path $destDir | Out-Null
} catch {
    Write-Host "  [ERRO] Nao foi possivel criar a pasta: $_" -ForegroundColor Red
    exit 1
}

# ============================================================
# ARQUIVOS A BAIXAR
# ============================================================
$baseUrl = "https://raw.githubusercontent.com/leosan123456/Otimiza-o-Windows-10/main"

$arquivos = @(
    @{ Nome = "OtimizadorWindows10_GUI.ps1"; Critico = $true  ; Desc = "Interface Grafica principal" }
    @{ Nome = "LiberarRAM.ps1"             ; Critico = $false ; Desc = "Script de liberacao de RAM"  }
    @{ Nome = "Otimizacao_Windows10_Performance.ps1"; Critico = $false; Desc = "Script CLI original" }
)

# ============================================================
# DOWNLOAD DOS ARQUIVOS
# ============================================================
Write-Host "  Baixando arquivos..." -ForegroundColor Yellow
Write-Host ""

$erros = 0
foreach ($arq in $arquivos) {
    $destFile = Join-Path $destDir $arq.Nome
    $url       = "$baseUrl/$($arq.Nome)"

    Write-Host "  [$($arq.Desc)]" -ForegroundColor DarkGray
    Write-Host "  Baixando $($arq.Nome)..." -NoNewline -ForegroundColor White

    try {
        Invoke-WebRequest -Uri $url -OutFile $destFile -UseBasicParsing -TimeoutSec 30
        $tamanhoKB = [math]::Round((Get-Item $destFile).Length / 1KB, 1)
        Write-Host " OK ($tamanhoKB KB)" -ForegroundColor Green
    } catch {
        Write-Host " FALHOU" -ForegroundColor Red
        Write-Host "    Erro: $_" -ForegroundColor DarkRed

        if ($arq.Critico) {
            Write-Host ""
            Write-Host "  [ERRO CRITICO] Arquivo principal nao pudo ser baixado." -ForegroundColor Red
            Write-Host "  Verifique sua conexao com a internet e tente novamente." -ForegroundColor Yellow
            Write-Host ""
            exit 1
        }
        $erros++
    }
    Write-Host ""
}

# ============================================================
# CRIAR ATALHO NO DESKTOP (opcional)
# ============================================================
try {
    $wsh      = New-Object -ComObject WScript.Shell
    $atalho   = $wsh.CreateShortcut("$env:USERPROFILE\Desktop\Otimizador Windows 10.lnk")
    $guiPath  = Join-Path $destDir "OtimizadorWindows10_GUI.ps1"
    $atalho.TargetPath     = "powershell.exe"
    $atalho.Arguments      = "-ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -File `"$guiPath`""
    $atalho.Description    = "Otimizador Windows 10"
    $atalho.WorkingDirectory = $destDir
    $atalho.IconLocation   = "powershell.exe,0"
    $atalho.Save()
    Write-Host "  Atalho criado na Area de Trabalho!" -ForegroundColor Green
    Write-Host ""
} catch {
    # Falha silenciosa - atalho nao e critico
}

# ============================================================
# RESUMO
# ============================================================
Write-Host "  ==========================================" -ForegroundColor Green
Write-Host "    Download concluido!                     " -ForegroundColor Green
Write-Host "  ==========================================" -ForegroundColor Green
Write-Host ""
if ($erros -gt 0) {
    Write-Host "  Aviso: $erros arquivo(s) nao puderam ser baixados (nao criticos)." -ForegroundColor Yellow
    Write-Host ""
}
Write-Host "  Iniciando interface grafica..." -ForegroundColor Cyan
Write-Host "  (Sera solicitada permissao de Administrador)" -ForegroundColor DarkGray
Write-Host ""
Start-Sleep -Seconds 1

# ============================================================
# EXECUTAR GUI COM PRIVILEGIOS DE ADMINISTRADOR
# ============================================================
$guiScript = Join-Path $destDir "OtimizadorWindows10_GUI.ps1"
Start-Process powershell.exe -Verb RunAs `
    -ArgumentList "-ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -File `"$guiScript`""
