@echo off
setlocal
REM ͬ��Զ�̴���ֿ�
echo ͬ��Զ�̴���ֿ�...
start "" /B /WAIT cmd /c "cd {user_path} && git pull"

REM ����С�Ǻ��㷨�������²���ͬ���û��ʿ�
echo ��ʼ���²���...
start /B /WAIT "" "{install_path}/WeaselDeployer.exe" /deploy
timeout /t 1
echo ��ʼͬ���û��ʿ�...
start /B /WAIT "" "{install_path}/WeaselDeployer.exe" /sync
echo [����]
endlocal
::pause
exit