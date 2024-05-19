@echo off
setlocal

set TASK_NAME="Rime仓库更新及用户词库同步"
set EXECUTABLE_PATH="%USERPROFILE%\AppData\Roaming\Rime\callUpdateRepoAndSync.vbe"
set RUN_TIME=12:36

REM 查询任务是否存在
schtasks /query /tn %TASK_NAME% >nul 2>&1
if %errorlevel% equ 0 (
    echo 任务已存在，准备更新...
    schtasks /delete /tn %TASK_NAME% /f
    echo 旧任务已删除。
)

REM 创建或更新任务
schtasks /create /tn %TASK_NAME% /tr %EXECUTABLE_PATH% /sc daily /st %RUN_TIME%
echo 任务创建或更新完成。

REM 立即执行任务
schtasks /run /tn %TASK_NAME%
echo 任务执行完成。

:: pause
