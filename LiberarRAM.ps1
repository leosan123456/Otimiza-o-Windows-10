# ============================================================
# LIBERADOR DE MEMORIA RAM - Windows 10
# Tecnicas: EmptyWorkingSet + Standby List + Modified List
# Requer: PowerShell 5.1+ e privilegios de Administrador
# ============================================================

param([switch]$Silencioso)

# Auto-elevacao para Administrador
$identity  = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]$identity
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $selfPath = if ($MyInvocation.MyCommand.Path) { $MyInvocation.MyCommand.Path } else { $PSCommandPath }
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -NoProfile -File `"$selfPath`""
    exit
}

# ============================================================
# TIPOS NATIVOS DO WINDOWS (P/Invoke)
# ============================================================
Add-Type -TypeDefinition @"
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

public class WinMemApi {

    // Abre handle de processo
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr OpenProcess(uint dwDesiredAccess, bool bInheritHandle, int dwProcessId);

    // Fecha handle
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool CloseHandle(IntPtr hObject);

    // Esvazia o Working Set de um processo (remove paginas da RAM fisica)
    [DllImport("psapi.dll", SetLastError = true)]
    public static extern bool EmptyWorkingSet(IntPtr hProcess);

    // API do NT para manipular listas de memoria do sistema
    [DllImport("ntdll.dll")]
    public static extern uint NtSetSystemInformation(
        int SystemInformationClass,
        IntPtr SystemInformation,
        int SystemInformationLength);

    // Acesso total ao processo
    public const uint PROCESS_ALL_ACCESS = 0x1F0FFF;

    // Esvazia Working Sets de todos os processos acessiveis
    public static int EmptyAllWorkingSets() {
        int count = 0;
        foreach (Process proc in Process.GetProcesses()) {
            try {
                IntPtr hProc = OpenProcess(PROCESS_ALL_ACCESS, false, proc.Id);
                if (hProc != IntPtr.Zero) {
                    EmptyWorkingSet(hProc);
                    CloseHandle(hProc);
                    count++;
                }
            } catch { }
        }
        return count;
    }

    // Libera a Modified Page List (paginas sujas nao gravadas ainda)
    // SystemMemoryListInformation = 80, MemoryFlushModifiedList = 3
    public static bool FlushModifiedList() {
        IntPtr buf = Marshal.AllocHGlobal(4);
        try {
            Marshal.WriteInt32(buf, 3);
            uint r = NtSetSystemInformation(80, buf, 4);
            return r == 0;
        } finally {
            Marshal.FreeHGlobal(buf);
        }
    }

    // Purga a Standby List (cache de paginas inativas na RAM)
    // SystemMemoryListInformation = 80, MemoryPurgeStandbyList = 4
    public static bool PurgeStandbyList() {
        IntPtr buf = Marshal.AllocHGlobal(4);
        try {
            Marshal.WriteInt32(buf, 4);
            uint r = NtSetSystemInformation(80, buf, 4);
            return r == 0;
        } finally {
            Marshal.FreeHGlobal(buf);
        }
    }
}
"@ -ErrorAction Stop

# ============================================================
# FUNCOES AUXILIARES
# ============================================================

function Get-RAMInfo {
    $os      = Get-CimInstance Win32_OperatingSystem
    $total   = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $free    = [math]::Round($os.FreePhysicalMemory      / 1MB, 2)
    $used    = [math]::Round($total - $free, 2)
    $pct     = [math]::Round(($used / $total) * 100, 1)
    return @{ Total = $total; Free = $free; Used = $used; Pct = $pct }
}

function Draw-Bar {
    param([double]$Percent, [int]$Width = 40)
    $filled = [int]($Percent / 100 * $Width)
    $bar    = "#" * $filled + "-" * ($Width - $filled)
    return "[$bar] $Percent%"
}

function Write-Step {
    param([string]$Icon, [string]$Text, [string]$Color = "White")
    Write-Host "  $Icon " -NoNewline
    Write-Host $Text -ForegroundColor $Color
}

# ============================================================
# INTERFACE DE CONSOLE
# ============================================================

if (-not $Silencioso) {
    $Host.UI.RawUI.ForegroundColor = "White"
    Clear-Host
    Write-Host ""
    Write-Host "  ============================================" -ForegroundColor Cyan
    Write-Host "      LIBERADOR DE MEMORIA RAM - Windows 10  " -ForegroundColor Cyan
    Write-Host "  ============================================" -ForegroundColor Cyan
    Write-Host ""
}

# --- RAM ANTES ---
Write-Step ">" "Lendo uso de memoria atual..." "Yellow"
$antes = Get-RAMInfo
Write-Host ""
Write-Host "  ANTES:" -ForegroundColor DarkGray
Write-Host "    Total : $($antes.Total) GB" -ForegroundColor Gray
Write-Host "    Em uso: $($antes.Used) GB ($($antes.Pct)%)" -ForegroundColor $(if ($antes.Pct -gt 80) { "Red" } elseif ($antes.Pct -gt 60) { "Yellow" } else { "Green" })
Write-Host "    Livre : $($antes.Free) GB" -ForegroundColor Gray
Write-Host "    $(Draw-Bar -Percent $antes.Pct)" -ForegroundColor $(if ($antes.Pct -gt 80) { "Red" } elseif ($antes.Pct -gt 60) { "Yellow" } else { "Cyan" })
Write-Host ""

Start-Sleep -Milliseconds 500

# ============================================================
# ETAPA 1: ESVAZIAR WORKING SETS DOS PROCESSOS
# ============================================================
Write-Step "1" "Esvaziando Working Sets de todos os processos..." "Cyan"
try {
    $count = [WinMemApi]::EmptyAllWorkingSets()
    Write-Step "   OK" "$count processos processados" "Green"
} catch {
    Write-Step "   AVISO" "Erro no EmptyWorkingSet: $_" "Yellow"
}
Start-Sleep -Milliseconds 800

# ============================================================
# ETAPA 2: LIBERAR MODIFIED PAGE LIST
# ============================================================
Write-Step "2" "Liberando Modified Page List (paginas sujas)..." "Cyan"
try {
    $ok = [WinMemApi]::FlushModifiedList()
    if ($ok) { Write-Step "   OK" "Modified List liberada" "Green" }
    else      { Write-Step "   AVISO" "FlushModifiedList retornou falha (normal em algumas versoes do SO)" "Yellow" }
} catch {
    Write-Step "   AVISO" "Erro: $_" "Yellow"
}
Start-Sleep -Milliseconds 800

# ============================================================
# ETAPA 3: PURGAR STANDBY LIST
# ============================================================
Write-Step "3" "Purgando Standby List (cache de paginas inativas)..." "Cyan"
try {
    $ok = [WinMemApi]::PurgeStandbyList()
    if ($ok) { Write-Step "   OK" "Standby List purgada" "Green" }
    else      { Write-Step "   AVISO" "PurgeStandbyList retornou falha (normal em algumas versoes do SO)" "Yellow" }
} catch {
    Write-Step "   AVISO" "Erro: $_" "Yellow"
}
Start-Sleep -Milliseconds 800

# ============================================================
# ETAPA 4: LIMPAR CACHE DNS
# ============================================================
Write-Step "4" "Limpando cache DNS..." "Cyan"
try {
    ipconfig /flushdns | Out-Null
    Write-Step "   OK" "Cache DNS limpo" "Green"
} catch {}

# ============================================================
# ETAPA 5: FORCANDO COLETA DE LIXO DO .NET
# ============================================================
Write-Step "5" "Forcando Garbage Collection do .NET runtime..." "Cyan"
try {
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    [System.GC]::Collect()
    Write-Step "   OK" "GC concluido" "Green"
} catch {}
Start-Sleep -Milliseconds 500

# ============================================================
# RESULTADO FINAL
# ============================================================
Write-Host ""
Start-Sleep -Milliseconds 300
$depois = Get-RAMInfo

$liberadoGB  = [math]::Round($depois.Free - $antes.Free, 2)
$liberadoMB  = [math]::Round($liberadoGB * 1024, 0)
$corResultado = if ($liberadoGB -gt 0) { "Green" } else { "Yellow" }

Write-Host "  ============================================" -ForegroundColor Green
Write-Host "    RESULTADO" -ForegroundColor Green
Write-Host "  ============================================" -ForegroundColor Green
Write-Host ""
Write-Host "  DEPOIS:" -ForegroundColor DarkGray
Write-Host "    Em uso: $($depois.Used) GB ($($depois.Pct)%)" -ForegroundColor $(if ($depois.Pct -gt 80) { "Red" } elseif ($depois.Pct -gt 60) { "Yellow" } else { "Green" })
Write-Host "    Livre : $($depois.Free) GB" -ForegroundColor Gray
Write-Host "    $(Draw-Bar -Percent $depois.Pct)" -ForegroundColor $(if ($depois.Pct -gt 80) { "Red" } elseif ($depois.Pct -gt 60) { "Yellow" } else { "Cyan" })
Write-Host ""

if ($liberadoGB -ge 0) {
    Write-Host "  >> MEMORIA LIBERADA: $liberadoGB GB ($liberadoMB MB) <<" -ForegroundColor $corResultado
    Write-Host "     Uso: $($antes.Pct)% -> $($depois.Pct)% (-$([math]::Abs($depois.Pct - $antes.Pct)) pp)" -ForegroundColor $corResultado
} else {
    Write-Host "  >> Uso aumentou ligeiramente durante o processo (normal)." -ForegroundColor Yellow
    Write-Host "     O sistema redistribuiu paginas automaticamente." -ForegroundColor Gray
}

Write-Host ""
Write-Host "  NOTA: O Windows pode realocar memoria em poucos segundos" -ForegroundColor DarkGray
Write-Host "        para manter o desempenho. Isso e comportamento normal." -ForegroundColor DarkGray
Write-Host ""
Write-Host "  ============================================" -ForegroundColor Cyan
Write-Host ""

if (-not $Silencioso) {
    Write-Host "  Pressione qualquer tecla para fechar..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
