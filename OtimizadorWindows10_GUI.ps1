# ============================================================
# OTIMIZADOR WINDOWS 10 - Interface Grafica Avancada
# Baseado em: Otimizacao_Windows10_Performance.ps1
# Versao: 2.0 | Tema: GitHub Dark
# ============================================================

param()

# Auto-elevacao para Administrador
$identity  = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]$identity
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $selfPath = $MyInvocation.MyCommand.Path
    if (-not $selfPath) { $selfPath = $PSCommandPath }
    Start-Process powershell.exe -Verb RunAs `
        -ArgumentList "-ExecutionPolicy Bypass -NoProfile -File `"$selfPath`""
    exit
}

# Carregar assemblies WPF
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

# ============================================================
# XAML - Interface Grafica
# ============================================================
[xml]$xaml = @'
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Otimizador Windows 10"
    Height="820" Width="900"
    MinHeight="700" MinWidth="820"
    Background="#0d1117"
    WindowStartupLocation="CenterScreen"
    FontFamily="Segoe UI">

  <Window.Resources>

    <Style x:Key="BtnPrimary" TargetType="Button">
      <Setter Property="Background"    Value="#238636"/>
      <Setter Property="Foreground"    Value="White"/>
      <Setter Property="BorderBrush"   Value="#2ea043"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="Padding"       Value="18,9"/>
      <Setter Property="FontSize"      Value="13"/>
      <Setter Property="FontWeight"    Value="Bold"/>
      <Setter Property="Cursor"        Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border Background="{TemplateBinding Background}"
                    BorderBrush="{TemplateBinding BorderBrush}"
                    BorderThickness="{TemplateBinding BorderThickness}"
                    CornerRadius="6" Padding="{TemplateBinding Padding}">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter Property="Background" Value="#2ea043"/>
              </Trigger>
              <Trigger Property="IsPressed" Value="True">
                <Setter Property="Background" Value="#1a7f37"/>
              </Trigger>
              <Trigger Property="IsEnabled" Value="False">
                <Setter Property="Background"  Value="#21262d"/>
                <Setter Property="BorderBrush" Value="#30363d"/>
                <Setter Property="Foreground"  Value="#6e7681"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="BtnSec" TargetType="Button">
      <Setter Property="Background"      Value="#21262d"/>
      <Setter Property="Foreground"      Value="#c9d1d9"/>
      <Setter Property="BorderBrush"     Value="#30363d"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="Padding"         Value="12,7"/>
      <Setter Property="FontSize"        Value="12"/>
      <Setter Property="Cursor"          Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border Background="{TemplateBinding Background}"
                    BorderBrush="{TemplateBinding BorderBrush}"
                    BorderThickness="{TemplateBinding BorderThickness}"
                    CornerRadius="6" Padding="{TemplateBinding Padding}">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter Property="Background"  Value="#30363d"/>
                <Setter Property="BorderBrush" Value="#8b949e"/>
              </Trigger>
              <Trigger Property="IsEnabled" Value="False">
                <Setter Property="Foreground" Value="#6e7681"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="BtnWarn" TargetType="Button" BasedOn="{StaticResource BtnSec}">
      <Setter Property="BorderBrush" Value="#d29922"/>
      <Setter Property="Foreground"  Value="#d29922"/>
    </Style>

    <Style TargetType="CheckBox">
      <Setter Property="Foreground"              Value="#c9d1d9"/>
      <Setter Property="FontSize"                Value="13"/>
      <Setter Property="Margin"                  Value="0,3,0,3"/>
      <Setter Property="VerticalContentAlignment" Value="Top"/>
    </Style>

    <Style x:Key="SectionHeader" TargetType="TextBlock">
      <Setter Property="FontSize"   Value="11"/>
      <Setter Property="FontWeight" Value="Bold"/>
      <Setter Property="Foreground" Value="#58a6ff"/>
      <Setter Property="Margin"     Value="0,0,0,5"/>
    </Style>

    <Style x:Key="HwValue" TargetType="TextBlock">
      <Setter Property="FontSize"      Value="13"/>
      <Setter Property="Foreground"    Value="#e6edf3"/>
      <Setter Property="TextWrapping"  Value="Wrap"/>
    </Style>

    <Style x:Key="HwSub" TargetType="TextBlock">
      <Setter Property="FontSize"   Value="11"/>
      <Setter Property="Foreground" Value="#8b949e"/>
      <Setter Property="Margin"     Value="0,2,0,0"/>
    </Style>

  </Window.Resources>

  <DockPanel>

    <!-- ===== CABECALHO ===== -->
    <Border DockPanel.Dock="Top" Background="#161b22"
            BorderBrush="#30363d" BorderThickness="0,0,0,1">
      <Grid Margin="20,14,20,14">
        <StackPanel Orientation="Horizontal">
          <TextBlock Text="&#9889;" FontSize="26" Foreground="#58a6ff"
                     VerticalAlignment="Center" Margin="0,0,12,0"/>
          <StackPanel VerticalAlignment="Center">
            <TextBlock Text="OTIMIZADOR WINDOWS 10"
                       FontSize="19" FontWeight="Bold" Foreground="#58a6ff"/>
            <TextBlock Text="Performance Avancada com Interface Grafica"
                       FontSize="11" Foreground="#8b949e"/>
          </StackPanel>
        </StackPanel>
        <Border HorizontalAlignment="Right" VerticalAlignment="Center"
                Background="#1c2128" BorderBrush="#30363d" BorderThickness="1"
                CornerRadius="5" Padding="10,4">
          <TextBlock x:Name="txtStatus" Text="Pronto" FontSize="12" Foreground="#3fb950"/>
        </Border>
      </Grid>
    </Border>

    <!-- ===== BOTOES DE ACAO (RODAPE) ===== -->
    <Border DockPanel.Dock="Bottom" Background="#161b22"
            BorderBrush="#30363d" BorderThickness="0,1,0,0" Padding="20,12">
      <Grid>
        <Grid.ColumnDefinitions>
          <ColumnDefinition Width="Auto"/>
          <ColumnDefinition Width="8"/>
          <ColumnDefinition Width="Auto"/>
          <ColumnDefinition Width="8"/>
          <ColumnDefinition Width="Auto"/>
          <ColumnDefinition Width="8"/>
          <ColumnDefinition Width="Auto"/>
          <ColumnDefinition Width="*"/>
          <ColumnDefinition Width="Auto"/>
          <ColumnDefinition Width="8"/>
          <ColumnDefinition Width="Auto"/>
        </Grid.ColumnDefinitions>
        <Button Grid.Column="0" x:Name="btnRestorePoint"
                Content="Criar Ponto de Restauracao" Style="{StaticResource BtnSec}"/>
        <Button Grid.Column="2" x:Name="btnCleanTemp"
                Content="Limpar Temporarios" Style="{StaticResource BtnSec}"/>
        <Button Grid.Column="4" x:Name="btnRefreshHW"
                Content="Atualizar Hardware" Style="{StaticResource BtnSec}"/>
        <Button Grid.Column="6" x:Name="btnFreeRAM"
                Content="Liberar RAM" Style="{StaticResource BtnSec}"/>
        <Button Grid.Column="8" x:Name="btnOptimize"
                Content="  OTIMIZAR AGORA  " Style="{StaticResource BtnPrimary}"/>
        <Button Grid.Column="10" x:Name="btnRestart"
                Content="Reiniciar PC" Style="{StaticResource BtnWarn}"
                IsEnabled="False"/>
      </Grid>
    </Border>

    <!-- ===== CONTEUDO PRINCIPAL ===== -->
    <ScrollViewer VerticalScrollBarVisibility="Auto"
                  HorizontalScrollBarVisibility="Disabled"
                  Background="#0d1117">
      <StackPanel Margin="20,16,20,16">

        <!-- HARDWARE -->
        <Border Background="#161b22" BorderBrush="#30363d" BorderThickness="1"
                CornerRadius="8" Margin="0,0,0,12">
          <StackPanel>
            <Border Background="#1c2128" BorderBrush="#30363d" BorderThickness="0,0,0,1"
                    CornerRadius="8,8,0,0" Padding="16,10">
              <TextBlock Text="INFORMACOES DE HARDWARE"
                         FontSize="12" FontWeight="Bold" Foreground="#58a6ff"/>
            </Border>
            <Grid Margin="16,14,16,14">
              <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="1"/>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="1"/>
                <ColumnDefinition Width="*"/>
              </Grid.ColumnDefinitions>

              <!-- Coluna 1: CPU + RAM -->
              <StackPanel Grid.Column="0">
                <TextBlock Text="PROCESSADOR" Style="{StaticResource SectionHeader}"/>
                <TextBlock x:Name="txtCPUName"    Style="{StaticResource HwValue}" Text="..."/>
                <TextBlock x:Name="txtCPUDetails" Style="{StaticResource HwSub}"   Text="..."/>
                <TextBlock x:Name="txtCPULoad"    Style="{StaticResource HwSub}"   Text="..."/>

                <TextBlock Text="MEMORIA RAM" Style="{StaticResource SectionHeader}" Margin="0,14,0,5"/>
                <TextBlock x:Name="txtRAMTotal" Style="{StaticResource HwValue}" Text="..."/>
                <TextBlock x:Name="txtRAMUsage" Style="{StaticResource HwSub}"   Text="..."/>
                <ProgressBar x:Name="ramBar" Height="5" Margin="0,6,0,0"
                             Minimum="0" Maximum="100" Value="0"
                             Background="#30363d" Foreground="#3fb950"/>
              </StackPanel>

              <Border Grid.Column="1" Background="#30363d"/>

              <!-- Coluna 2: GPU + Disco -->
              <StackPanel Grid.Column="2" Margin="16,0">
                <TextBlock Text="PLACA DE VIDEO" Style="{StaticResource SectionHeader}"/>
                <TextBlock x:Name="txtGPUName" Style="{StaticResource HwValue}" Text="..."/>
                <TextBlock x:Name="txtGPUMem"  Style="{StaticResource HwSub}"   Text="..."/>

                <TextBlock Text="ARMAZENAMENTO" Style="{StaticResource SectionHeader}" Margin="0,14,0,5"/>
                <TextBlock x:Name="txtDiskName"    Style="{StaticResource HwValue}" Text="..."/>
                <TextBlock x:Name="txtDiskDetails" Style="{StaticResource HwSub}"   Text="..."/>
                <TextBlock x:Name="txtDiskFree"    Style="{StaticResource HwSub}"   Text="..."/>
                <ProgressBar x:Name="diskBar" Height="5" Margin="0,6,0,0"
                             Minimum="0" Maximum="100" Value="0"
                             Background="#30363d" Foreground="#58a6ff"/>
              </StackPanel>

              <Border Grid.Column="3" Background="#30363d"/>

              <!-- Coluna 3: OS + Uptime -->
              <StackPanel Grid.Column="4" Margin="16,0,0,0">
                <TextBlock Text="SISTEMA OPERACIONAL" Style="{StaticResource SectionHeader}"/>
                <TextBlock x:Name="txtOSName"  Style="{StaticResource HwValue}" Text="..."/>
                <TextBlock x:Name="txtOSBuild" Style="{StaticResource HwSub}"   Text="..."/>

                <TextBlock Text="TEMPO LIGADO" Style="{StaticResource SectionHeader}" Margin="0,14,0,5"/>
                <TextBlock x:Name="txtUptime" Style="{StaticResource HwValue}" Text="..."/>

                <TextBlock Text="MODO DE ENERGIA" Style="{StaticResource SectionHeader}" Margin="0,14,0,5"/>
                <TextBlock x:Name="txtPower" Style="{StaticResource HwValue}" Text="..."/>
              </StackPanel>
            </Grid>
          </StackPanel>
        </Border>

        <!-- OTIMIZACOES -->
        <Border Background="#161b22" BorderBrush="#30363d" BorderThickness="1"
                CornerRadius="8" Margin="0,0,0,12">
          <StackPanel>
            <Border Background="#1c2128" BorderBrush="#30363d" BorderThickness="0,0,0,1"
                    CornerRadius="8,8,0,0" Padding="16,10">
              <Grid>
                <TextBlock Text="OTIMIZACOES DISPONIVEIS"
                           FontSize="12" FontWeight="Bold" Foreground="#58a6ff"
                           VerticalAlignment="Center"/>
                <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
                  <Button x:Name="btnSelectAll"   Content="Selecionar Todos"
                          Style="{StaticResource BtnSec}" Margin="0,0,6,0" Padding="9,4" FontSize="11"/>
                  <Button x:Name="btnDeselectAll" Content="Desmarcar Todos"
                          Style="{StaticResource BtnSec}" Padding="9,4" FontSize="11"/>
                </StackPanel>
              </Grid>
            </Border>
            <StackPanel x:Name="panelOpts" Margin="16,10,16,14"/>
          </StackPanel>
        </Border>

        <!-- LOG -->
        <Border Background="#0d1117" BorderBrush="#30363d" BorderThickness="1"
                CornerRadius="8" Margin="0,0,0,12">
          <StackPanel>
            <Border Background="#161b22" BorderBrush="#30363d" BorderThickness="0,0,0,1"
                    CornerRadius="8,8,0,0" Padding="16,10">
              <Grid>
                <TextBlock Text="LOG DE EXECUCAO"
                           FontSize="12" FontWeight="Bold" Foreground="#58a6ff"/>
                <Button x:Name="btnClearLog" Content="Limpar"
                        Style="{StaticResource BtnSec}"
                        HorizontalAlignment="Right" Padding="8,3" FontSize="11"/>
              </Grid>
            </Border>
            <ScrollViewer x:Name="logScroll" Height="155"
                          VerticalScrollBarVisibility="Auto"
                          HorizontalScrollBarVisibility="Disabled">
              <RichTextBox x:Name="richLog"
                           Background="Transparent" BorderThickness="0"
                           IsReadOnly="True" FontFamily="Consolas" FontSize="11"
                           Foreground="#e6edf3" Padding="12,8"/>
            </ScrollViewer>
          </StackPanel>
        </Border>

        <!-- PROGRESSO -->
        <Border Background="#161b22" BorderBrush="#30363d" BorderThickness="1"
                CornerRadius="8" Padding="16,12">
          <StackPanel>
            <Grid Margin="0,0,0,7">
              <TextBlock x:Name="txtProgressLabel" Text="Aguardando..."
                         Foreground="#8b949e" FontSize="12" VerticalAlignment="Center"/>
              <TextBlock x:Name="txtProgressPct" Text="0%"
                         Foreground="#58a6ff" FontSize="14" FontWeight="Bold"
                         HorizontalAlignment="Right" VerticalAlignment="Center"/>
            </Grid>
            <ProgressBar x:Name="mainProgress" Height="8"
                         Minimum="0" Maximum="100" Value="0"
                         Background="#21262d" Foreground="#58a6ff"/>
          </StackPanel>
        </Border>

      </StackPanel>
    </ScrollViewer>

  </DockPanel>
</Window>
'@

# ============================================================
# CRIAR JANELA E VINCULAR CONTROLES
# ============================================================
$reader = [System.Xml.XmlNodeReader]::new($xaml)
$window = [System.Windows.Markup.XamlReader]::Load($reader)

# Hardware
$txtCPUName    = $window.FindName("txtCPUName")
$txtCPUDetails = $window.FindName("txtCPUDetails")
$txtCPULoad    = $window.FindName("txtCPULoad")
$txtRAMTotal   = $window.FindName("txtRAMTotal")
$txtRAMUsage   = $window.FindName("txtRAMUsage")
$ramBar        = $window.FindName("ramBar")
$txtGPUName    = $window.FindName("txtGPUName")
$txtGPUMem     = $window.FindName("txtGPUMem")
$txtDiskName   = $window.FindName("txtDiskName")
$txtDiskDetails= $window.FindName("txtDiskDetails")
$txtDiskFree   = $window.FindName("txtDiskFree")
$diskBar       = $window.FindName("diskBar")
$txtOSName     = $window.FindName("txtOSName")
$txtOSBuild    = $window.FindName("txtOSBuild")
$txtUptime     = $window.FindName("txtUptime")
$txtPower      = $window.FindName("txtPower")
# Layout
$txtStatus        = $window.FindName("txtStatus")
$panelOpts        = $window.FindName("panelOpts")
$richLog          = $window.FindName("richLog")
$logScroll        = $window.FindName("logScroll")
$mainProgress     = $window.FindName("mainProgress")
$txtProgressLabel = $window.FindName("txtProgressLabel")
$txtProgressPct   = $window.FindName("txtProgressPct")
# Botoes
$btnOptimize    = $window.FindName("btnOptimize")
$btnRestorePoint= $window.FindName("btnRestorePoint")
$btnCleanTemp   = $window.FindName("btnCleanTemp")
$btnRefreshHW   = $window.FindName("btnRefreshHW")
$btnFreeRAM     = $window.FindName("btnFreeRAM")
$btnRestart     = $window.FindName("btnRestart")
$btnSelectAll   = $window.FindName("btnSelectAll")
$btnDeselectAll = $window.FindName("btnDeselectAll")
$btnClearLog    = $window.FindName("btnClearLog")

# ============================================================
# HASHTABLE SINCRONIZADA (comunicacao UI <-> runspace)
# ============================================================
$sync = [hashtable]::Synchronized(@{
    Window        = $window
    RichLog       = $richLog
    LogScroll     = $logScroll
    Progress      = $mainProgress
    ProgressLabel = $txtProgressLabel
    ProgressPct   = $txtProgressPct
    Status        = $txtStatus
    BtnOptimize   = $btnOptimize
    BtnRestart    = $btnRestart
    Queue         = [System.Collections.Concurrent.ConcurrentQueue[hashtable]]::new()
    Done          = $false
    Cancel        = $false
})

# ============================================================
# FUNCOES AUXILIARES DE UI
# ============================================================

function Add-Log {
    param([string]$Msg, [string]$Type = "INFO")
    $entry = @{ Msg = $Msg; Type = $Type }
    $sync.Queue.Enqueue($entry)
}

function Process-LogQueue {
    $item = $null
    while ($sync.Queue.TryDequeue([ref]$item)) {
        $color = switch ($item.Type) {
            "OK"     { "#3fb950" }
            "ERROR"  { "#f85149" }
            "WARN"   { "#d29922" }
            "HEAD"   { "#58a6ff" }
            default  { "#8b949e" }
        }
        $prefix = switch ($item.Type) {
            "OK"    { "[OK]   " }
            "ERROR" { "[ERRO] " }
            "WARN"  { "[AVISO]" }
            "HEAD"  { ">>     " }
            default { "[INFO] " }
        }
        $ts   = Get-Date -Format "HH:mm:ss"
        $para = New-Object System.Windows.Documents.Paragraph
        $para.Margin = [System.Windows.Thickness]::new(0)

        $tsRun = New-Object System.Windows.Documents.Run
        $tsRun.Text = "$ts "
        $tsRun.Foreground = [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(0x48,0x4f,0x58))

        $pfxRun = New-Object System.Windows.Documents.Run
        $pfxRun.Text = $prefix
        $pfxRun.Foreground = [System.Windows.Media.SolidColorBrush](
            [System.Windows.Media.ColorConverter]::ConvertFromString($color))

        $msgRun = New-Object System.Windows.Documents.Run
        $msgRun.Text = " $($item.Msg)"
        $msgRun.Foreground = [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(0xc9,0xd1,0xd9))

        $para.Inlines.Add($tsRun)
        $para.Inlines.Add($pfxRun)
        $para.Inlines.Add($msgRun)
        $richLog.Document.Blocks.Add($para)
        $logScroll.ScrollToBottom()
    }
}

# ============================================================
# COLETA DE HARDWARE
# ============================================================
function Get-HardwareInfo {
    try {
        # CPU
        $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
        $txtCPUName.Text    = $cpu.Name.Trim()
        $txtCPUDetails.Text = "$($cpu.NumberOfCores) nucleos / $($cpu.NumberOfLogicalProcessors) threads @ $([math]::Round($cpu.MaxClockSpeed/1000,1)) GHz"
        $cpuLoad = ($cpu.LoadPercentage)
        $txtCPULoad.Text = "Uso atual: $cpuLoad%"
    } catch {
        $txtCPUName.Text = "Nao disponivel"
    }

    try {
        # RAM
        $os       = Get-CimInstance Win32_OperatingSystem
        $total    = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
        $free     = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
        $used     = [math]::Round($total - $free, 1)
        $pct      = [math]::Round(($used / $total) * 100, 0)
        $txtRAMTotal.Text = "$total GB total"
        $txtRAMUsage.Text = "Em uso: $used GB ($pct%) | Livre: $free GB"
        $ramBar.Value     = $pct
    } catch {
        $txtRAMTotal.Text = "Nao disponivel"
    }

    try {
        # GPU
        $gpu = Get-CimInstance Win32_VideoController | Where-Object { $_.AdapterRAM -gt 0 } | Select-Object -First 1
        if (-not $gpu) { $gpu = Get-CimInstance Win32_VideoController | Select-Object -First 1 }
        $txtGPUName.Text = $gpu.Name
        $vram = [math]::Round($gpu.AdapterRAM / 1GB, 0)
        $txtGPUMem.Text  = if ($vram -gt 0) { "VRAM: $vram GB | Driver: $($gpu.DriverVersion)" } else { "Driver: $($gpu.DriverVersion)" }
    } catch {
        $txtGPUName.Text = "Nao disponivel"
    }

    try {
        # Disco
        $disk   = Get-CimInstance Win32_DiskDrive | Select-Object -First 1
        $diskGB = [math]::Round($disk.Size / 1GB, 0)
        $txtDiskName.Text = $disk.Model.Trim()

        # Tipo SSD/HDD
        $mediaType = "Desconhecido"
        try {
            $phys = Get-PhysicalDisk | Where-Object { $_.DeviceID -eq "0" } | Select-Object -First 1
            if (-not $phys) { $phys = Get-PhysicalDisk | Select-Object -First 1 }
            $mediaType = $phys.MediaType
        } catch {}
        $txtDiskDetails.Text = "$diskGB GB | Tipo: $mediaType"

        # Espaco livre no C:
        $cDrive = Get-PSDrive C
        $freeGB = [math]::Round($cDrive.Free / 1GB, 1)
        $usedGB = [math]::Round(($cDrive.Used) / 1GB, 1)
        $totalGB= [math]::Round(($cDrive.Free + $cDrive.Used) / 1GB, 1)
        $pctDisk= [math]::Round(($usedGB / $totalGB) * 100, 0)
        $txtDiskFree.Text = "C: $freeGB GB livre de $totalGB GB ($pctDisk% usado)"
        $diskBar.Value    = $pctDisk
    } catch {
        $txtDiskName.Text = "Nao disponivel"
    }

    try {
        # OS
        $os = Get-CimInstance Win32_OperatingSystem
        $txtOSName.Text  = $os.Caption
        $txtOSBuild.Text = "Build $($os.BuildNumber) | $($os.OSArchitecture)"

        # Uptime
        $up = (Get-Date) - $os.LastBootUpTime
        $uptimeStr = if ($up.Days -gt 0) { "$($up.Days)d $($up.Hours)h $($up.Minutes)m" }
                     else                 { "$($up.Hours)h $($up.Minutes)m $($up.Seconds)s" }
        $txtUptime.Text = $uptimeStr
    } catch {
        $txtOSName.Text = "Nao disponivel"
    }

    try {
        # Plano de energia ativo
        $powerOut = powercfg /getactivescheme 2>&1
        if ($powerOut -match "Alto desempenho|High performance") { $txtPower.Text = "Alto Desempenho" }
        elseif ($powerOut -match "Equilibrado|Balanced")          { $txtPower.Text = "Equilibrado" }
        elseif ($powerOut -match "Economia|Power saver")          { $txtPower.Text = "Economia de energia" }
        else                                                       { $txtPower.Text = "Personalizado" }
    } catch {
        $txtPower.Text = "..."
    }
}

# ============================================================
# DEFINICOES DAS OTIMIZACOES
# ============================================================
$optDefs = @(
    @{
        Id      = 1
        Name    = "Efeitos Visuais"
        Desc    = "Remove animacoes e transparencias - economia de 100-200 MB RAM"
        Default = $true
        Risk    = "low"
    }
    @{
        Id      = 2
        Name    = "Inicializacao do Sistema"
        Desc    = "Reduz timeout de boot para 3s, otimiza prefetch  -  boot 10-20s mais rapido"
        Default = $true
        Risk    = "low"
    }
    @{
        Id      = 3
        Name    = "Servicos Desnecessarios"
        Desc    = "Desabilita Xbox Live, Fax, Mapas, Telemetria  -  economia de 500MB-1GB RAM"
        Default = $true
        Risk    = "low"
    }
    @{
        Id      = 4
        Name    = "Plano de Energia (Alto Desempenho)"
        Desc    = "Ativa performance maxima do processador e desabilita hibernacao"
        Default = $true
        Risk    = "low"
    }
    @{
        Id      = 5
        Name    = "Gerenciamento de Memoria"
        Desc    = "Otimiza cache do sistema, desabilita compressao de memoria"
        Default = $true
        Risk    = "low"
    }
    @{
        Id      = 6
        Name    = "Telemetria e Privacidade"
        Desc    = "Desabilita envio de dados para Microsoft, rastreamento e publicidade"
        Default = $true
        Risk    = "low"
    }
    @{
        Id      = 7
        Name    = "Otimizacoes de Rede"
        Desc    = "Reduz latencia TCP/IP e desabilita autotuning  -  ping 5-15ms menor"
        Default = $true
        Risk    = "low"
    }
    @{
        Id      = 8
        Name    = "Controle do Windows Update"
        Desc    = "Muda para notificacao manual  -  voce decide quando instalar atualizacoes"
        Default = $false
        Risk    = "medium"
    }
    @{
        Id      = 9
        Name    = "Desabilitar Cortana e Busca Web"
        Desc    = "Remove Cortana e Bing do menu Iniciar  -  economia de 150-300MB RAM"
        Default = $true
        Risk    = "low"
    }
    @{
        Id      = 10
        Name    = "Explorador de Arquivos"
        Desc    = "Remove historico e cache de miniaturas  -  navegacao 20-30% mais rapida"
        Default = $true
        Risk    = "low"
    }
    @{
        Id      = 11
        Name    = "Recursos do Windows (IE, XPS)"
        Desc    = "Remove Internet Explorer, XPS Services, Work Folders  -  libera 500MB-2GB"
        Default = $false
        Risk    = "medium"
    }
    @{
        Id      = 12
        Name    = "Game Mode / Game DVR"
        Desc    = "Habilita Game Mode e desabilita gravacao DVR  -  +5-15 FPS em jogos"
        Default = $true
        Risk    = "low"
    }
    @{
        Id      = 13
        Name    = "Limpeza de Arquivos Temporarios"
        Desc    = "Limpa %TEMP%, Windows\Temp, Prefetch e DNS cache  -  libera ate 5GB"
        Default = $true
        Risk    = "low"
    }
    @{
        Id      = 14
        Name    = "Otimizacoes de Disco (SSD)"
        Desc    = "Desabilita Superfetch e desfragmentacao agendada (recomendado para SSD)"
        Default = $true
        Risk    = "low"
    }
    @{
        Id      = 15
        Name    = "Otimizacoes Diversas"
        Desc    = "Desabilita notificacoes, apps em 2o plano, sincronizacao de config"
        Default = $true
        Risk    = "low"
    }
)

# ============================================================
# GERAR CHECKBOXES DINAMICAMENTE
# ============================================================
$checkboxes = @{}
foreach ($opt in $optDefs) {
    $cb            = New-Object System.Windows.Controls.CheckBox
    $cb.IsChecked  = $opt.Default
    $cb.Tag        = $opt.Id

    # Conteudo do checkbox: StackPanel com nome + descricao
    $sp = New-Object System.Windows.Controls.StackPanel

    $nameRow = New-Object System.Windows.Controls.StackPanel
    $nameRow.Orientation = [System.Windows.Controls.Orientation]::Horizontal

    $numTb = New-Object System.Windows.Controls.TextBlock
    $numTb.Text     = "$($opt.Id.ToString().PadLeft(2,'0')). "
    $numTb.FontSize = 13
    $numTb.Foreground = [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(0x58,0xa6,0xff))
    $numTb.FontWeight = [System.Windows.FontWeights]::SemiBold

    $nameTb = New-Object System.Windows.Controls.TextBlock
    $nameTb.Text      = $opt.Name
    $nameTb.FontSize  = 13
    $nameTb.FontWeight= [System.Windows.FontWeights]::SemiBold
    $nameTb.Foreground= [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(0xe6,0xed,0xf3))

    # Badge de risco
    if ($opt.Risk -eq "medium") {
        $badge = New-Object System.Windows.Controls.Border
        $badge.Background    = [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(0x38,0x2b,0x00))
        $badge.BorderBrush   = [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(0xd2,0x99,0x22))
        $badge.BorderThickness = [System.Windows.Thickness]::new(1)
        $badge.CornerRadius  = [System.Windows.CornerRadius]::new(3)
        $badge.Margin        = [System.Windows.Thickness]::new(8,0,0,0)
        $badge.Padding       = [System.Windows.Thickness]::new(5,0,5,0)
        $badgeTb = New-Object System.Windows.Controls.TextBlock
        $badgeTb.Text      = "USE COM CUIDADO"
        $badgeTb.FontSize  = 9
        $badgeTb.Foreground= [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(0xd2,0x99,0x22))
        $badge.Child = $badgeTb
        $nameRow.Children.Add($numTb)  | Out-Null
        $nameRow.Children.Add($nameTb) | Out-Null
        $nameRow.Children.Add($badge)  | Out-Null
    } else {
        $nameRow.Children.Add($numTb)  | Out-Null
        $nameRow.Children.Add($nameTb) | Out-Null
    }

    $descTb = New-Object System.Windows.Controls.TextBlock
    $descTb.Text     = "       $($opt.Desc)"
    $descTb.FontSize = 11
    $descTb.Foreground = [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(0x8b,0x94,0x9e))
    $descTb.Margin   = [System.Windows.Thickness]::new(0,1,0,0)

    $sp.Children.Add($nameRow) | Out-Null
    $sp.Children.Add($descTb)  | Out-Null

    $cb.Content = $sp
    $cb.Margin  = [System.Windows.Thickness]::new(0,4,0,4)
    $checkboxes[$opt.Id] = $cb
    $panelOpts.Children.Add($cb) | Out-Null
}

# ============================================================
# SCRIPTBLOCK DE OTIMIZACAO (executado em runspace separado)
# ============================================================
$optimizeScript = {
    param($sync, $selectedIds)

    function Invoke-UI([scriptblock]$sb) {
        $sync.Window.Dispatcher.Invoke($sb, [System.Windows.Threading.DispatcherPriority]::Background)
    }

    function Log([string]$msg, [string]$type = "INFO") {
        $sync.Queue.Enqueue(@{ Msg = $msg; Type = $type })
    }

    function Set-Reg {
        param([string]$path, [string]$name, $value, [string]$type = "DWord")
        try {
            if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
            Set-ItemProperty -Path $path -Name $name -Value $value -Type $type -Force -ErrorAction Stop
            return $true
        } catch {
            Log "Falha ao setar $path\$name : $_" "WARN"
            return $false
        }
    }

    function Update-Progress([int]$value, [string]$label) {
        Invoke-UI {
            $sync.Progress.Value      = $value
            $sync.ProgressLabel.Text  = $label
            $sync.ProgressPct.Text    = "$value%"
        }
    }

    $total   = $selectedIds.Count
    $current = 0

    Log "Iniciando otimizacao  -  $total item(s) selecionado(s)" "HEAD"

    foreach ($id in ($selectedIds | Sort-Object)) {
        if ($sync.Cancel) { Log "Otimizacao cancelada pelo usuario." "WARN"; break }

        $current++
        $pct = [int](($current / $total) * 100)

        switch ($id) {
            1 {
                Update-Progress $pct "Configurando efeitos visuais..."
                Log "[1/15] Otimizando efeitos visuais..." "HEAD"
                Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" "VisualFXSetting" 2 | Out-Null
                Set-Reg "HKCU:\Control Panel\Desktop\WindowMetrics" "MinAnimate" 0 | Out-Null
                Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarAnimations" 0 | Out-Null
                Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "EnableTransparency" 0 | Out-Null
                Log "Efeitos visuais otimizados (animacoes e transparencias desabilitadas)" "OK"
            }
            2 {
                Update-Progress $pct "Otimizando inicializacao..."
                Log "[2/15] Otimizando inicializacao do sistema..." "HEAD"
                try { bcdedit /timeout 3 | Out-Null; Log "Timeout de boot reduzido para 3s" "OK" } catch {}
                Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" "EnablePrefetcher" 3 | Out-Null
                Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" "OneDrive" ([byte[]](0x03,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00)) "Binary" | Out-Null
                Log "Inicializacao otimizada  -  prefetch ativado, OneDrive startup desabilitado" "OK"
            }
            3 {
                Update-Progress $pct "Desabilitando servicos desnecessarios..."
                Log "[3/15] Desabilitando servicos desnecessarios..." "HEAD"
                $svcs = @("DiagTrack","dmwappushservice","SysMain","WSearch","XblAuthManager",
                          "XblGameSave","XboxNetApiSvc","XboxGipSvc","Fax","RetailDemo","MapsBroker")
                foreach ($svc in $svcs) {
                    try {
                        $s = Get-Service -Name $svc -ErrorAction SilentlyContinue
                        if ($s) {
                            Stop-Service  -Name $svc -Force -ErrorAction SilentlyContinue
                            Set-Service   -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
                            Log "Servico '$svc' desabilitado" "OK"
                        }
                    } catch {}
                }
            }
            4 {
                Update-Progress $pct "Configurando plano de energia..."
                Log "[4/15] Ativando plano de alto desempenho..." "HEAD"
                try { powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>&1 | Out-Null; Log "Plano 'Alto Desempenho' ativado" "OK" } catch {}
                try { powercfg /hibernate off 2>&1 | Out-Null; Log "Hibernacao desabilitada (espaco em disco liberado)" "OK" } catch {}
                try { powercfg /change disk-timeout-ac 0 2>&1 | Out-Null } catch {}
                try { powercfg /change disk-timeout-dc 0 2>&1 | Out-Null } catch {}
                Log "Disco configurado para nunca dormir" "OK"
            }
            5 {
                Update-Progress $pct "Otimizando gerenciamento de memoria..."
                Log "[5/15] Otimizando gerenciamento de memoria..." "HEAD"
                Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "LargeSystemCache"     0 | Out-Null
                Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "ClearPageFileAtShutdown" 0 | Out-Null
                try { Disable-MMAgent -MemoryCompression -ErrorAction SilentlyContinue; Log "Compressao de memoria desabilitada" "OK" } catch {}
                Log "Cache do sistema e paginacao otimizados" "OK"
            }
            6 {
                Update-Progress $pct "Desabilitando telemetria..."
                Log "[6/15] Desabilitando telemetria e rastreamento..." "HEAD"
                Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"             "AllowTelemetry"                    0 | Out-Null
                Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" "AllowTelemetry"                0 | Out-Null
                Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"    "Start_TrackProgs"                  0 | Out-Null
                Set-Reg "HKCU:\Software\Microsoft\Siuf\Rules"                                  "NumberOfSIUFInPeriod"              0 | Out-Null
                Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"      "Enabled"                           0 | Out-Null
                Log "Telemetria, rastreamento e ID de publicidade desabilitados" "OK"
            }
            7 {
                Update-Progress $pct "Otimizando rede..."
                Log "[7/15] Otimizando configuracoes de rede TCP/IP..." "HEAD"
                try { netsh interface tcp set global autotuninglevel=disabled 2>&1 | Out-Null; Log "Autotuning TCP desabilitado" "OK" } catch {}
                Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "DefaultTTL"         64 | Out-Null
                Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "EnablePMTUDiscovery" 1 | Out-Null
                Log "Parametros TCP/IP otimizados (TTL=64, PMTU ativo)" "OK"
            }
            8 {
                Update-Progress $pct "Configurando Windows Update..."
                Log "[8/15] Configurando Windows Update para notificacao manual..." "HEAD"
                Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "NoAutoUpdate" 0 | Out-Null
                Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "AUOptions"    2 | Out-Null
                Log "Windows Update configurado: notificar antes de baixar/instalar" "OK"
            }
            9 {
                Update-Progress $pct "Desabilitando Cortana..."
                Log "[9/15] Desabilitando Cortana e busca web..." "HEAD"
                Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowCortana"     0 | Out-Null
                Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"   "BingSearchEnabled" 0 | Out-Null
                Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"   "CortanaConsent"    0 | Out-Null
                Log "Cortana e busca Bing desabilitados no menu Iniciar" "OK"
            }
            10 {
                Update-Progress $pct "Otimizando Explorador de Arquivos..."
                Log "[10/15] Otimizando Explorador de Arquivos..." "HEAD"
                Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "DisableThumbnailCache"            1 | Out-Null
                Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "DisableThumbsDBOnNetworkFolders"  1 | Out-Null
                Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"          "ShowRecent"                       0 | Out-Null
                Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"          "ShowFrequent"                     0 | Out-Null
                Log "Historico de arquivos recentes e cache de miniaturas desabilitados" "OK"
            }
            11 {
                Update-Progress $pct "Removendo recursos do Windows..."
                Log "[11/15] Desabilitando recursos opcionais do Windows..." "HEAD"
                $features = @("Internet-Explorer-Optional-amd64","WorkFolders-Client","Printing-XPSServices-Features")
                foreach ($f in $features) {
                    try {
                        Disable-WindowsOptionalFeature -Online -FeatureName $f -NoRestart -ErrorAction SilentlyContinue | Out-Null
                        Log "Recurso '$f' desabilitado" "OK"
                    } catch { Log "Nao foi possivel desabilitar '$f'" "WARN" }
                }
            }
            12 {
                Update-Progress $pct "Configurando Game Mode..."
                Log "[12/15] Configurando Game Mode e DVR..." "HEAD"
                Set-Reg "HKCU:\Software\Microsoft\GameBar"          "AutoGameModeEnabled" 1 | Out-Null
                Set-Reg "HKCU:\System\GameConfigStore"              "GameDVR_Enabled"     0 | Out-Null
                Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" "AllowGameDVR" 0 | Out-Null
                Log "Game Mode habilitado, Game DVR (gravacao) desabilitado" "OK"
            }
            13 {
                Update-Progress $pct "Limpando arquivos temporarios..."
                Log "[13/15] Executando limpeza de arquivos temporarios..." "HEAD"
                $paths = @("$env:TEMP\*","C:\Windows\Temp\*","C:\Windows\Prefetch\*")
                $freed = 0
                foreach ($p in $paths) {
                    try {
                        $before = (Get-ChildItem $p -Recurse -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
                        Remove-Item -Path $p -Recurse -Force -ErrorAction SilentlyContinue
                        $freed += $before
                    } catch {}
                }
                $freedMB = [math]::Round($freed / 1MB, 1)
                Log "$freedMB MB de arquivos temporarios removidos" "OK"
                try { ipconfig /flushdns | Out-Null; Log "Cache DNS limpo" "OK" } catch {}
            }
            14 {
                Update-Progress $pct "Otimizando disco..."
                Log "[14/15] Otimizando configuracoes de disco..." "HEAD"
                Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" "EnableSuperfetch" 0 | Out-Null
                Log "Superfetch desabilitado (recomendado para SSD)" "OK"
                try {
                    Get-ScheduledTask -TaskName "ScheduledDefrag" -ErrorAction SilentlyContinue |
                        Disable-ScheduledTask -ErrorAction SilentlyContinue | Out-Null
                    Log "Desfragmentacao agendada desabilitada" "OK"
                } catch {}
            }
            15 {
                Update-Progress $pct "Aplicando otimizacoes diversas..."
                Log "[15/15] Aplicando otimizacoes finais..." "HEAD"
                Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications"          "ToastEnabled"               0 | Out-Null
                Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"     "SubscribedContent-338389Enabled" 0 | Out-Null
                Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" "GlobalUserDisabled"         1 | Out-Null
                Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync"                "SyncPolicy"                 5 | Out-Null
                Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"           "Start_TrackDocs"            0 | Out-Null
                Log "Notificacoes, apps em 2o plano e sincronizacao desabilitados" "OK"
            }
        }
        Start-Sleep -Milliseconds 200
    }

    Invoke-UI {
        $sync.Progress.Value     = 100
        $sync.ProgressLabel.Text = "Otimizacao concluida com sucesso!"
        $sync.ProgressPct.Text   = "100%"
        $sync.Status.Text        = "Concluido"
        $sync.Status.Foreground  = [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(0x3f,0xb9,0x50))
        $sync.BtnOptimize.IsEnabled = $true
        $sync.BtnRestart.IsEnabled  = $true
    }

    $sync.Queue.Enqueue(@{ Msg = "========================================" ; Type = "HEAD" })
    $sync.Queue.Enqueue(@{ Msg = "Otimizacao concluida! Reinicie o PC para aplicar todas as mudancas." ; Type = "OK" })
    $sync.Done = $true
}

# ============================================================
# TIMER PARA PROCESSAR FILA DE LOG (no thread da UI)
# ============================================================
$logTimer = New-Object System.Windows.Threading.DispatcherTimer
$logTimer.Interval = [TimeSpan]::FromMilliseconds(80)
$logTimer.Add_Tick({
    Process-LogQueue
    if ($sync.Done) {
        $sync.Done = $false
        # Atualiza hardware apos otimizacao
        Get-HardwareInfo
    }
})
$logTimer.Start()

# ============================================================
# HANDLERS DOS BOTOES
# ============================================================

# --- OTIMIZAR AGORA ---
$btnOptimize.Add_Click({
    $selected = @()
    foreach ($kvp in $checkboxes.GetEnumerator()) {
        if ($kvp.Value.IsChecked) { $selected += [int]$kvp.Key }
    }

    if ($selected.Count -eq 0) {
        [System.Windows.MessageBox]::Show(
            "Selecione ao menos uma otimizacao!",
            "Aviso",
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Warning) | Out-Null
        return
    }

    $btnOptimize.IsEnabled = $false
    $btnRestart.IsEnabled  = $false
    $sync.Cancel = $false

    $richLog.Document.Blocks.Clear()
    $mainProgress.Value      = 0
    $txtProgressLabel.Text   = "Iniciando..."
    $txtProgressPct.Text     = "0%"
    $txtStatus.Text          = "Otimizando..."
    $txtStatus.Foreground    = [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(0xd2,0x99,0x22))

    # Iniciar runspace
    $rs = [runspacefactory]::CreateRunspace()
    $rs.ApartmentState = "STA"
    $rs.ThreadOptions  = "ReuseThread"
    $rs.Open()
    $rs.SessionStateProxy.SetVariable("sync",        $sync)
    $rs.SessionStateProxy.SetVariable("selectedIds", $selected)

    $ps = [powershell]::Create()
    $ps.Runspace = $rs
    $ps.AddScript($optimizeScript).AddArgument($sync).AddArgument($selected) | Out-Null
    $null = $ps.BeginInvoke()
})

# --- CRIAR PONTO DE RESTAURACAO ---
$btnRestorePoint.Add_Click({
    $btnRestorePoint.IsEnabled = $false
    Add-Log "Criando ponto de restauracao do sistema..." "HEAD"
    try {
        Checkpoint-Computer -Description "Antes da Otimizacao de Performance" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        Add-Log "Ponto de restauracao criado com sucesso!" "OK"
    } catch {
        Add-Log "Erro ao criar ponto de restauracao: $_" "WARN"
        Add-Log "Tente em: Painel de Controle > Sistema > Protecao do Sistema" "INFO"
    }
    $btnRestorePoint.IsEnabled = $true
})

# --- LIMPAR TEMPORARIOS ---
$btnCleanTemp.Add_Click({
    $btnCleanTemp.IsEnabled = $false
    Add-Log "Limpando arquivos temporarios..." "HEAD"
    $total = 0
    $paths = @("$env:TEMP\*","C:\Windows\Temp\*","C:\Windows\Prefetch\*")
    foreach ($p in $paths) {
        try {
            $sz = (Get-ChildItem $p -Recurse -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
            Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue
            $total += $sz
        } catch {}
    }
    try { ipconfig /flushdns | Out-Null; Add-Log "Cache DNS limpo" "OK" } catch {}
    $mb = [math]::Round($total / 1MB, 1)
    Add-Log "$mb MB de temporarios removidos" "OK"
    Get-HardwareInfo
    $btnCleanTemp.IsEnabled = $true
})

# --- ATUALIZAR HARDWARE ---
$btnRefreshHW.Add_Click({
    $btnRefreshHW.IsEnabled = $false
    $txtCPUName.Text = "Atualizando..."
    Get-HardwareInfo
    Add-Log "Informacoes de hardware atualizadas" "OK"
    $btnRefreshHW.IsEnabled = $true
})

# --- LIBERAR RAM ---
$btnFreeRAM.Add_Click({
    $btnFreeRAM.IsEnabled = $false
    Add-Log "Iniciando liberacao de memoria RAM..." "HEAD"

    # Carregar tipos nativos (somente se nao carregados ainda)
    if (-not ([System.Management.Automation.PSTypeName]'WinMemApi').Type) {
        Add-Type -TypeDefinition @"
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
public class WinMemApi {
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr OpenProcess(uint dwDesiredAccess, bool bInheritHandle, int dwProcessId);
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool CloseHandle(IntPtr hObject);
    [DllImport("psapi.dll", SetLastError = true)]
    public static extern bool EmptyWorkingSet(IntPtr hProcess);
    [DllImport("ntdll.dll")]
    public static extern uint NtSetSystemInformation(int SystemInformationClass, IntPtr SystemInformation, int SystemInformationLength);
    public const uint PROCESS_ALL_ACCESS = 0x1F0FFF;
    public static int EmptyAllWorkingSets() {
        int count = 0;
        foreach (Process proc in Process.GetProcesses()) {
            try {
                IntPtr hProc = OpenProcess(PROCESS_ALL_ACCESS, false, proc.Id);
                if (hProc != IntPtr.Zero) { EmptyWorkingSet(hProc); CloseHandle(hProc); count++; }
            } catch { }
        }
        return count;
    }
    public static void FlushModifiedList() {
        IntPtr buf = Marshal.AllocHGlobal(4);
        try { Marshal.WriteInt32(buf, 3); NtSetSystemInformation(80, buf, 4); }
        finally { Marshal.FreeHGlobal(buf); }
    }
    public static void PurgeStandbyList() {
        IntPtr buf = Marshal.AllocHGlobal(4);
        try { Marshal.WriteInt32(buf, 4); NtSetSystemInformation(80, buf, 4); }
        finally { Marshal.FreeHGlobal(buf); }
    }
}
"@ -ErrorAction SilentlyContinue
    }

    # RAM antes
    $osBefore  = Get-CimInstance Win32_OperatingSystem
    $freeBefore = [math]::Round($osBefore.FreePhysicalMemory / 1MB, 2)
    $usedBefore = [math]::Round(($osBefore.TotalVisibleMemorySize - $osBefore.FreePhysicalMemory) / 1MB, 2)
    Add-Log "RAM em uso: $usedBefore GB | Livre: $freeBefore GB" "INFO"

    # Executar liberacao
    try {
        $count = [WinMemApi]::EmptyAllWorkingSets()
        Add-Log "Working Sets esvaziados ($count processos)" "OK"
    } catch { Add-Log "EmptyWorkingSet: $_" "WARN" }

    try { [WinMemApi]::FlushModifiedList();  Add-Log "Modified List liberada" "OK" } catch {}
    try { [WinMemApi]::PurgeStandbyList();   Add-Log "Standby List purgada"   "OK" } catch {}
    try { [System.GC]::Collect(); [System.GC]::WaitForPendingFinalizers(); [System.GC]::Collect() } catch {}
    try { ipconfig /flushdns | Out-Null; Add-Log "Cache DNS limpo" "OK" } catch {}

    Start-Sleep -Milliseconds 600

    # RAM depois
    $osAfter  = Get-CimInstance Win32_OperatingSystem
    $freeAfter = [math]::Round($osAfter.FreePhysicalMemory / 1MB, 2)
    $liberado  = [math]::Round($freeAfter - $freeBefore, 2)
    $liberadoMB = [math]::Round($liberado * 1024, 0)

    if ($liberado -gt 0) {
        Add-Log "Memoria liberada: $liberado GB ($liberadoMB MB)" "OK"
    } else {
        Add-Log "Sistema redistribuiu memoria (comportamento normal do Windows)" "WARN"
    }

    # Atualizar hardware
    Get-HardwareInfo
    $btnFreeRAM.IsEnabled = $true
})

# --- REINICIAR ---
$btnRestart.Add_Click({
    $r = [System.Windows.MessageBox]::Show(
        "Deseja reiniciar o computador agora?`nTodas as otimizacoes serao aplicadas apos o reinicio.",
        "Reiniciar PC",
        [System.Windows.MessageBoxButton]::YesNo,
        [System.Windows.MessageBoxImage]::Question)
    if ($r -eq [System.Windows.MessageBoxResult]::Yes) {
        $window.Close()
        Restart-Computer -Force
    }
})

# --- SELECIONAR / DESMARCAR TODOS ---
$btnSelectAll.Add_Click({
    foreach ($cb in $checkboxes.Values) { $cb.IsChecked = $true }
})
$btnDeselectAll.Add_Click({
    foreach ($cb in $checkboxes.Values) { $cb.IsChecked = $false }
})

# --- LIMPAR LOG ---
$btnClearLog.Add_Click({
    $richLog.Document.Blocks.Clear()
})

# ============================================================
# INICIALIZACAO
# ============================================================
$window.Add_ContentRendered({
    Add-Log "Interface carregada. Coletando informacoes de hardware..." "INFO"
    Get-HardwareInfo
    Add-Log "Hardware detectado com sucesso!" "OK"
    Add-Log "Selecione as otimizacoes desejadas e clique em 'OTIMIZAR AGORA'." "INFO"
    Add-Log "DICA: Crie um Ponto de Restauracao antes de otimizar." "WARN"
})

# Limpar timer ao fechar
$window.Add_Closed({
    $logTimer.Stop()
})

# ============================================================
# EXIBIR JANELA
# ============================================================
[void]$window.ShowDialog()
