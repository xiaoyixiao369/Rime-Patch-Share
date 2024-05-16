@echo off
start "" /B /WAIT cmd /c "cd %USERPROFILE%\AppData\Roaming\Rime && git pull"
start "" /B /WAIT "C:\Program Files (x86)\Rime\weasel-0.16.0\WeaselDeployer.exe" /deploy
start "" /B /WAIT "C:\Program Files (x86)\Rime\weasel-0.16.0\WeaselDeployer.exe" /sync
