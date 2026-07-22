# TIRA O DISCO C DAS EXCLUSÕES

Remove-MpPreference -ExclusionPath "C:\"

# APAGA NOTEPAD.EXE DO TEMP

Remove-Item -Path "$env:TEMP\notepad.exe" -Force -ErrorAction SilentlyContinue

# APAGA IMPORTER (PASTA) DO TEMP

Remove-Item -Path "$env:TEMP\Importer_0_4" -Recurse -Force -ErrorAction SilentlyContinue

# ATIVA UAC 

Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 5
