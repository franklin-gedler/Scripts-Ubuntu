@echo off
mkdir C:\tmp
cd C:\tmp
(
	echo echo ''
	echo echo ''
	echo echo ''
	echo echo ''
	echo echo ''
	echo echo ''
	echo echo ''
	echo echo '#################################'
	echo echo 'Descargando Team Viewer Despegar'
	echo echo '#################################'
	echo Invoke-WebRequest https://github.com/franklin-gedler/Only-Download/releases/download/TVH/TVH-Win.msi -OutFile C:\tmp\TeamViewerHostSetup.msi
	echo Invoke-WebRequest https://github.com/franklin-gedler/Only-Download/releases/download/TVH/politicas.reg -OutFile C:\tmp\politicas.reg
	echo cls
	echo echo ''
	echo echo '################################'
	echo echo 'Instalando Team Viewer Despegar'
	echo echo '################################'
	echo Start-Process msiexec.exe -Wait -ArgumentList '/I C:\tmp\TeamViewerHostSetup.msi /quiet /passive'
	echo Start-Process regedit.exe -Wait -ArgumentList '/S C:\tmp\politicas.reg'
	echo echo ''
	) > C:\tmp\installTVH.ps1
runas /user:admindesp "PowerShell.exe -executionpolicy Unrestricted C:\tmp\installTVH.ps1"
pause
cls
echo #######################
echo       Instalado 
echo #######################
pause
rd /s /q C:\tmp\