@echo off
setlocal
REM 同步远程代码仓库
echo 同步远程代码仓库...
start "" /B /WAIT cmd /c "cd {user_path} && git pull"

REM 重启小狼毫算法服务，重新部署，同步用户词库
echo 开始重新部署...
start /B /WAIT "" "{install_path}/WeaselDeployer.exe" /deploy
timeout /t 1
echo 开始同步用户词库...
start /B /WAIT "" "{install_path}/WeaselDeployer.exe" /sync
echo [结束]
endlocal
::pause
exit