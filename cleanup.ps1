# TIRA O DISCO C DAS EXCLUSÕES

Remove-MpPreference -ExclusionPath "C:\"

# ATIVA UAC 

Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 5

# APAGA NOTEPAD.EXE DO TEMP

Remove-Item -Path "$env:TEMP\notepad.exe" -Force -ErrorAction SilentlyContinue

# APAGA IMPORTER (PASTA) DO TEMP

Remove-Item -Path "$env:TEMP\Importer_0_4" -Recurse -Force -ErrorAction SilentlyContinue

# ============================================================
# REATIVAÇÃO COMPLETA DO WINDOWS DEFENDER
# Deve ser executado como ADMINISTRADOR
# ============================================================

Write-Host "[*] Iniciando reativação do Defender..." -ForegroundColor Cyan

# 1. Remove todas as políticas de grupo/registro que bloqueiam
Write-Host "[1] Removendo políticas..." -ForegroundColor Yellow
$paths = @(
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender",
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection",
    "HKLM:\SOFTWARE\Microsoft\Windows Defender\Features",
    "HKLM:\SOFTWARE\Microsoft\Windows Defender\Security Center\App and Browser Protection"
)
foreach ($p in $paths) {
    if (Test-Path $p) {
        Remove-Item -Path $p -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "  Removido: $p" -ForegroundColor Gray
    }
}

# 2. Remove exclusões de pastas (incluindo C:\)
Write-Host "[2] Removendo exclusões..." -ForegroundColor Yellow
Remove-MpPreference -ExclusionPath "C:\" -ErrorAction SilentlyContinue
Remove-MpPreference -ExclusionProcess "notepad.exe" -ErrorAction SilentlyContinue
Remove-MpPreference -ExclusionExtension ".exe" -ErrorAction SilentlyContinue
# Remove todas as exclusões (se quiser)
# Clear-MpPreference -ExclusionPath -ErrorAction SilentlyContinue

# 3. Reativa todas as proteções
Write-Host "[3] Reativando proteções..." -ForegroundColor Yellow
$prefs = @{
    DisableRealtimeMonitoring = $false
    DisableBehaviorMonitoring = $false
    DisableBlockAtFirstSeen = $false
    DisableIOAVProtection = $false
    DisablePrivacyMode = $false
    SignatureDisableUpdateOnStartupWithoutEngine = $false
    DisableArchiveScanning = $false
    DisableIntrusionPreventionSystem = $false
    DisableScriptScanning = $false
    SubmitSamplesConsent = 2
}
foreach ($key in $prefs.Keys) {
    Set-MpPreference -$key $prefs[$key] -ErrorAction SilentlyContinue
}

# 4. Reinicia o serviço do Defender
Write-Host "[4] Reiniciando serviço WinDefend..." -ForegroundColor Yellow
Stop-Service WinDefend -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Start-Service WinDefend -ErrorAction SilentlyContinue

# 5. Força atualização de assinaturas
Write-Host "[5] Atualizando assinaturas..." -ForegroundColor Yellow
Update-MpSignature -ErrorAction SilentlyContinue

# 6. Verifica status
Write-Host "[6] Status atual:" -ForegroundColor Yellow
$status = Get-MpComputerStatus
$props = @(
    "AntivirusEnabled",
    "RealTimeProtectionEnabled",
    "BehaviorMonitorEnabled",
    "IoavProtectionEnabled",
    "NISEnabled",
    "OnAccessProtectionEnabled"
)
foreach ($prop in $props) {
    $val = $status.$prop
    if ($val -eq $true) {
        Write-Host "  [+] $prop = ATIVADO" -ForegroundColor Green
    } elseif ($val -eq $false) {
        Write-Host "  [-] $prop = DESATIVADO" -ForegroundColor Red
    } else {
        Write-Host "  [?] $prop = $val" -ForegroundColor Gray
    }
}

Write-Host "[*] Reativação concluída." -ForegroundColor Cyan
