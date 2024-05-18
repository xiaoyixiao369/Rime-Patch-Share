@echo off
start "" /B /WAIT cmd /c "cd {user_path} && git pull"
start "" /B /WAIT "{install_path}/WeaselDeployer.exe" /deploy
start "" /B /WAIT "{install_path}/WeaselDeployer.exe" /sync