@echo off
setlocal

set TASK_NAME="Rime�ֿ���¼��û��ʿ�ͬ��"
set EXECUTABLE_PATH="%USERPROFILE%\AppData\Roaming\Rime\callUpdateRepoAndSync.vbe"
set RUN_TIME=12:36

REM ��ѯ�����Ƿ����
schtasks /query /tn %TASK_NAME% >nul 2>&1
if %errorlevel% equ 0 (
    echo �����Ѵ��ڣ�׼������...
    schtasks /delete /tn %TASK_NAME% /f
    echo ��������ɾ����
)

REM �������������
schtasks /create /tn %TASK_NAME% /tr %EXECUTABLE_PATH% /sc daily /st %RUN_TIME%
echo ���񴴽��������ɡ�

REM ����ִ������
schtasks /run /tn %TASK_NAME%
echo ����ִ����ɡ�

:: pause
