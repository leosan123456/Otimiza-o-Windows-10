#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Script de Otimização de Performance do Windows 10
    
.DESCRIPTION
    Este script configura políticas e ajustes do sistema para maximizar
    a performance do Windows 10, desabilitando recursos desnecessários
    e otimizando configurações críticas.
    
.NOTES
    Nome do Arquivo: Otimizacao_Windows10_Performance.ps1
    Autor: Otimização Avançada
    Requer: PowerShell 5.1+ e privilégios de Administrador
    Compatível: Windows 10 (todas as versões)
    
.WARNING
    - Execute por sua conta e risco
    - Crie um ponto de restauração antes de executar
    - Algumas mudanças requerem reinicialização
#>

# ============================================================================
# CONFIGURAÇÕES INICIAIS
# ============================================================================

$ErrorActionPreference = "Continue"
$WarningPreference = "Continue"

# Cores para output
$Host.UI.RawUI.ForegroundColor = "White"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  OTIMIZAÇÃO DE PERFORMANCE WINDOWS 10" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar privilégios de administrador
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "[ERRO] Este script requer privilégios de Administrador!" -ForegroundColor Red
    Write-Host "Execute o PowerShell como Administrador e tente novamente." -ForegroundColor Yellow
    Pause
    Exit
}

# Criar ponto de restauração
Write-Host "[INFO] Criando ponto de restauração do sistema..." -ForegroundColor Yellow
try {
    Checkpoint-Computer -Description "Antes da Otimização de Performance" -RestorePointType "MODIFY_SETTINGS"
    Write-Host "[OK] Ponto de restauração criado com sucesso!" -ForegroundColor Green
} catch {
    Write-Host "[AVISO] Não foi possível criar ponto de restauração: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host ""
Start-Sleep -Seconds 2

# ============================================================================
# FUNÇÃO AUXILIAR - DEFINIR REGISTRO
# ============================================================================

function Set-RegistryValue {
    param(
        [string]$Path,
        [string]$Name,
        [object]$Value,
        [string]$Type = "DWord"
    )
    
    try {
        if (!(Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
        }
        New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force | Out-Null
        return $true
    } catch {
        Write-Host "[ERRO] Falha ao configurar $Path\$Name : $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# ============================================================================
# 1. OTIMIZAÇÕES DE DESEMPENHO VISUAL
# ============================================================================

Write-Host "[1/15] Configurando otimizações visuais..." -ForegroundColor Cyan

# Desabilitar efeitos visuais para melhor desempenho
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2

# Desabilitar animações
Set-RegistryValue -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value 0
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 0

# Desabilitar transparência
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0

Write-Host "   [OK] Efeitos visuais otimizados" -ForegroundColor Green

# ============================================================================
# 2. OTIMIZAÇÕES DE INICIALIZAÇÃO
# ============================================================================

Write-Host "[2/15] Otimizando inicialização do sistema..." -ForegroundColor Cyan

# Desabilitar programas desnecessários na inicialização via registro
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" -Name "OneDrive" -Value ([byte[]](0x03,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00)) -Type Binary

# Configurar timeout de boot
bcdedit /timeout 3 | Out-Null

# Otimizar menu de inicialização
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name "EnablePrefetcher" -Value 3

Write-Host "   [OK] Inicialização otimizada" -ForegroundColor Green

# ============================================================================
# 3. DESABILITAR SERVIÇOS DESNECESSÁRIOS
# ============================================================================

Write-Host "[3/15] Desabilitando serviços desnecessários..." -ForegroundColor Cyan

$servicesToDisable = @(
    "DiagTrack",                    # Connected User Experiences and Telemetry
    "dmwappushservice",             # WAP Push Message Routing Service
    "SysMain",                      # Superfetch (pode melhorar em SSDs)
    "WSearch",                      # Windows Search (se não usar busca frequente)
    "XblAuthManager",               # Xbox Live Auth Manager
    "XblGameSave",                  # Xbox Live Game Save
    "XboxNetApiSvc",                # Xbox Live Networking Service
    "XboxGipSvc",                   # Xbox Accessory Management Service
    "Fax",                          # Fax Service
    "RetailDemo",                   # Retail Demo Service
    "MapsBroker"                    # Downloaded Maps Manager
)

foreach ($service in $servicesToDisable) {
    try {
        $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
        if ($svc) {
            Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
            Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Host "   [OK] Serviço $service desabilitado" -ForegroundColor Green
        }
    } catch {
        Write-Host "   [AVISO] Não foi possível desabilitar $service" -ForegroundColor Yellow
    }
}

# ============================================================================
# 4. OTIMIZAÇÕES DE ENERGIA
# ============================================================================

Write-Host "[4/15] Configurando plano de energia para alto desempenho..." -ForegroundColor Cyan

# Ativar plano de alto desempenho
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

# Desabilitar hibernação (libera espaço em disco)
powercfg /hibernate off

# Desabilitar sleep do disco rígido
powercfg /change disk-timeout-ac 0
powercfg /change disk-timeout-dc 0

Write-Host "   [OK] Plano de energia configurado" -ForegroundColor Green

# ============================================================================
# 5. OTIMIZAÇÕES DE MEMÓRIA E PROCESSADOR
# ============================================================================

Write-Host "[5/15] Otimizando gerenciamento de memória..." -ForegroundColor Cyan

# Desabilitar arquivo de paginação (apenas se tiver RAM suficiente - 16GB+)
# CUIDADO: Descomente apenas se tiver RAM adequada
# Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "PagingFiles" -Value "" -Type String

# Otimizar cache do sistema
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "LargeSystemCache" -Value 0
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "ClearPageFileAtShutdown" -Value 0

# Desabilitar compactação de memória
Disable-MMAgent -MemoryCompression -ErrorAction SilentlyContinue

Write-Host "   [OK] Memória otimizada" -ForegroundColor Green

# ============================================================================
# 6. DESABILITAR TELEMETRIA E PRIVACIDADE
# ============================================================================

Write-Host "[6/15] Desabilitando telemetria e rastreamento..." -ForegroundColor Cyan

# Desabilitar telemetria
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0
Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Value 0

# Desabilitar rastreamento de aplicativos
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Value 0

# Desabilitar feedback do Windows
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Value 0

# Desabilitar ID de publicidade
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value 0

Write-Host "   [OK] Telemetria desabilitada" -ForegroundColor Green

# ============================================================================
# 7. OTIMIZAÇÕES DE REDE
# ============================================================================

Write-Host "[7/15] Otimizando configurações de rede..." -ForegroundColor Cyan

# Desabilitar autotuning
netsh interface tcp set global autotuninglevel=disabled | Out-Null

# Otimizar TCP/IP
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "DefaultTTL" -Value 64
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "EnablePMTUDiscovery" -Value 1

# Desabilitar Nagle's Algorithm para menor latência
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" -Name "TcpAckFrequency" -Value 1
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" -Name "TCPNoDelay" -Value 1

Write-Host "   [OK] Rede otimizada" -ForegroundColor Green

# ============================================================================
# 8. DESABILITAR WINDOWS UPDATE AUTOMÁTICO (OPCIONAL)
# ============================================================================

Write-Host "[8/15] Configurando Windows Update..." -ForegroundColor Cyan

# Configurar para notificar antes de baixar e instalar
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -Value 0
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUOptions" -Value 2

Write-Host "   [OK] Windows Update configurado" -ForegroundColor Green

# ============================================================================
# 9. DESABILITAR CORTANA E BUSCA WEB
# ============================================================================

Write-Host "[9/15] Desabilitando Cortana e busca web..." -ForegroundColor Cyan

# Desabilitar Cortana
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Value 0

# Desabilitar busca web no menu Iniciar
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Value 0

Write-Host "   [OK] Cortana e busca web desabilitados" -ForegroundColor Green

# ============================================================================
# 10. OTIMIZAÇÕES DO EXPLORADOR DE ARQUIVOS
# ============================================================================

Write-Host "[10/15] Otimizando Explorador de Arquivos..." -ForegroundColor Cyan

# Desabilitar histórico de arquivos recentes
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowRecent" -Value 0
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowFrequent" -Value 0

# Desabilitar visualização de miniaturas em rede
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisableThumbnailCache" -Value 1
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisableThumbsDBOnNetworkFolders" -Value 1

Write-Host "   [OK] Explorador de Arquivos otimizado" -ForegroundColor Green

# ============================================================================
# 11. DESABILITAR RECURSOS DO WINDOWS DESNECESSÁRIOS
# ============================================================================

Write-Host "[11/15] Desabilitando recursos desnecessários do Windows..." -ForegroundColor Cyan

$featuresToDisable = @(
    "Internet-Explorer-Optional-amd64",
    "MediaPlayback",
    "WorkFolders-Client",
    "Printing-XPSServices-Features"
)

foreach ($feature in $featuresToDisable) {
    try {
        Disable-WindowsOptionalFeature -Online -FeatureName $feature -NoRestart -ErrorAction SilentlyContinue | Out-Null
        Write-Host "   [OK] Recurso $feature desabilitado" -ForegroundColor Green
    } catch {
        Write-Host "   [AVISO] Não foi possível desabilitar $feature" -ForegroundColor Yellow
    }
}

# ============================================================================
# 12. OTIMIZAÇÕES DE JOGOS (GAME MODE)
# ============================================================================

Write-Host "[12/15] Configurando Game Mode..." -ForegroundColor Cyan

# Habilitar Game Mode
Set-RegistryValue -Path "HKCU:\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Value 1

# Desabilitar Game DVR
Set-RegistryValue -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Value 0

Write-Host "   [OK] Game Mode configurado" -ForegroundColor Green

# ============================================================================
# 13. LIMPEZA DE ARQUIVOS TEMPORÁRIOS
# ============================================================================

Write-Host "[13/15] Executando limpeza de arquivos temporários..." -ForegroundColor Cyan

# Limpar arquivos temporários
Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue

# Limpar cache DNS
ipconfig /flushdns | Out-Null

Write-Host "   [OK] Limpeza concluída" -ForegroundColor Green

# ============================================================================
# 14. OTIMIZAÇÕES DE DISCO
# ============================================================================

Write-Host "[14/15] Otimizando configurações de disco..." -ForegroundColor Cyan

# Desabilitar indexação (se usar SSD)
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name "EnableSuperfetch" -Value 0

# Desabilitar desfragmentação agendada em SSDs
Get-ScheduledTask -TaskName "ScheduledDefrag" -ErrorAction SilentlyContinue | Disable-ScheduledTask -ErrorAction SilentlyContinue

Write-Host "   [OK] Disco otimizado" -ForegroundColor Green

# ============================================================================
# 15. OTIMIZAÇÕES DIVERSAS
# ============================================================================

Write-Host "[15/15] Aplicando otimizações finais..." -ForegroundColor Cyan

# Desabilitar notificações de ação
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -Value 0

# Desabilitar dicas do Windows
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Value 0

# Desabilitar apps em segundo plano
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Value 1

# Desabilitar sincronização de configurações
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync" -Name "SyncPolicy" -Value 5

# Otimizar menu Iniciar
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackDocs" -Value 0

Write-Host "   [OK] Otimizações finais aplicadas" -ForegroundColor Green

# ============================================================================
# FINALIZAÇÃO
# ============================================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  OTIMIZAÇÃO CONCLUÍDA COM SUCESSO!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Resumo das otimizações aplicadas:" -ForegroundColor Cyan
Write-Host "  • Efeitos visuais otimizados"
Write-Host "  • Inicialização acelerada"
Write-Host "  • Serviços desnecessários desabilitados"
Write-Host "  • Plano de energia configurado para alto desempenho"
Write-Host "  • Memória e processador otimizados"
Write-Host "  • Telemetria desabilitada"
Write-Host "  • Rede otimizada"
Write-Host "  • Cortana desabilitada"
Write-Host "  • Game Mode habilitado"
Write-Host "  • Arquivos temporários limpos"
Write-Host "  • Disco otimizado"
Write-Host ""
Write-Host "IMPORTANTE:" -ForegroundColor Yellow
Write-Host "  • Reinicie o computador para aplicar todas as mudanças" -ForegroundColor Yellow
Write-Host "  • Use o Ponto de Restauração caso deseje reverter" -ForegroundColor Yellow
Write-Host "  • Algumas mudanças podem requerer ajustes manuais" -ForegroundColor Yellow
Write-Host ""
Write-Host "Deseja reiniciar o computador agora? (S/N): " -NoNewline -ForegroundColor Cyan
$resposta = Read-Host

if ($resposta -eq "S" -or $resposta -eq "s") {
    Write-Host ""
    Write-Host "Reiniciando em 10 segundos..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    Restart-Computer -Force
} else {
    Write-Host ""
    Write-Host "Lembre-se de reiniciar o computador manualmente!" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "Pressione qualquer tecla para ferir..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
