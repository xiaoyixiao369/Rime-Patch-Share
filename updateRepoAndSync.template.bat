@echo off
setlocal
:: ------------------------------------------------------------------------
:: 注意：
:: 1. 为了让中文在cmd窗口中不显示成乱码，本文件的编码格式需要为ANSI编码
:: 2. 设备同步配置文件installation.yaml中sync_dir的路径地址中要使用\\
:: ------------------------------------------------------------------------
:: 功能：
:: 1. 备份当前设备用户词库文件（设备词库目录下的userDictBakDir目录） 
:: 2. 清理当前设备用户词库 
:: 3. 清理历史备份的用户词库文件 
:: 4. 同步远程代码仓库
:: 5. 重新部署，同步用户词库
:: ------------------------------------------------------------------------
:: 声明：
:: 1. 调试/使用本脚本前请先做好用户词库数据备份，使用过程中导致的数据丢失自行负责
:: 2. 如果被删除的用户词在执行本脚本后又出现了，请检查其它设备的词库中是否存在相同的词
:: 3. 如果不需要备份功能，请自行注释或删除相关代码
:: ------------------------------------------------------------------------
:: 可修改的设置
:: 历史备份的用户词库文件保留天数
set "userDictBakStoreDays=30"

:: ------------------------------------------------------------------------
:: 以下内容无须修改：前提是使用雾凇拼音的代码仓库
REM 计算操作时间，格式为：1970-01-01 00:00
for /F "tokens=2 delims==." %%a in ('wmic OS GET LocalDateTime /VALUE') do set "_datetime=%%a"
set "_formatted_date=%_datetime:~0,4%-%_datetime:~4,2%-%_datetime:~6,2%"
set "_formatted_time=%_datetime:~8,2%-%_datetime:~10,2%"
set "curTime=%_formatted_date%_%_formatted_time%"
echo 当前操作时间：%curTime%

REM 关闭小狼毫算法服务
echo 关闭小狼毫算法服务...
taskkill /IM:WeaselServer.exe /F
timeout 1

REM 开始删除缓存词库目录中的文件
echo 开始删除缓存词库目录中的文件
del /s /q "{user_path}\rime_ice.userdb\*"

REM 从installation.yaml文件中解析用户词库同步目录，注意：设备同步配置文件installation.yaml中sync_dir的路径地址中要使用\\
echo 获取用户同步配置...
:: 必须要执行下面的cd代码，否则任务计划无法执行成功
cd {user_path}
set "installationFilePath={user_path}/installation.yaml"
for /f "tokens=* delims=:" %%a in ('type "%installationFilePath%" ^| findstr /C:"sync_dir:"') do (
    set "syncDirLine=%%a"
)
set "syncDirSubStr=%syncDirLine:*:=%"
set "syncDirWithDoubleQuotes=%syncDirSubStr:~1,-1%"
set "syncDir=%syncDirWithDoubleQuotes:"=%"

for /f "tokens=* delims=:" %%a in ('type "%installationFilePath%" ^| findstr /C:"installation_id:"') do (
    set "installationIdLine=%%a"
)
set "installationIdSubStr=%installationIdLine:*:=%"
set "installationId=%installationIdSubStr:~1%"

echo 用户词库同步目录：%syncDir%
echo 用户词库同步标识（设备）：%installationId%
set userDictDir=%syncDir%\\%installationId%
echo 当前设备同步目录：%userDictDir%

REM 操作的用户词库
set "zhDictFileName=rime_ice.userdb.txt"
set "enDictFileName=melt_eng.userdb.txt"
set "zhDictFile=%userDictDir%\\%zhDictFileName%"
set "enDictFile=%userDictDir%\\%enDictFileName%"
echo 中文用户词库文件： %zhDictFile%
echo 英文用户词库文件： %enDictFile%

:: ------- 备份与清理开始，不需要备份功能请删除此小节 -------
REM 备份当前用户词库
echo 备份当前用户词库...
set "userDictBakDir=%userDictDir%\\userDictBakDir
set "zhDictBakFile=%userDictBakDir%\\%zhDictFileName%.%curTime%"
set "enDictBakFile=%userDictBakDir%\\%enDictFileName%.%curTime%"
echo 备份用户词库目录为： %userDictBakDir%
:: 检测备份目录是否存在，如果不存在则创建
if not exist "%userDictBakDir%" mkdir "%userDictBakDir%"
copy %zhDictFile% %zhDictBakFile%
echo 已备份中文用户词库文件到： %zhDictBakFile%
copy %enDictFile% %enDictBakFile%
echo 已备份英文用户词库文件到： %enDictBakFile%

REM 清理历史备份文件
echo 清理历史备份文件...
for /r "%userDictBakDir%" %%f in (*) do (
    if /i "%%~tf" lss "%date:~0,8% - %userDictBakStoreDays%" del "%%f"
)
:: ------------------------------------- 备份与清理结束 -----------------------------------

REM 清理中文词库
echo 开始清理中文词库: %zhDictFile%
set "zhTempfile=%zhDictFile%.temp"
REM 将不包含 "c=0","c=-" 的行复制到临时文件，并替换现有中文词库文件
findstr /V /C:"c=0" %zhDictFile% | findstr /V /C:"c=-" > %zhTempfile%
move /Y %zhTempfile% %zhDictFile%

REM 清理英文词库
echo 开始清理英文词库...
echo 开始清理英文词库: %enDictFile%
set "enTempfile=%enDictFile%.temp"
REM 将不包含 "c=0","c=-" 的行复制到临时文件，并替换现有英文词库文件
findstr /V /C:"c=0" %enDictFile% | findstr /V /C:"c=-" > %enTempfile%
move /Y  %enTempfile% %enDictFile%

REM 同步远程代码仓库
echo 同步远程代码仓库...
start "" /B /WAIT cmd /c "cd {user_path} && git pull"

REM 重启小狼毫算法服务，重新部署，同步用户词库
echo 重启小狼毫算法服务...
start /B /SEPARATE /HIGH "" "{install_path}/WeaselServer.exe"
timeout /t 1
echo 开始重新部署...
start /B /WAIT "" "{install_path}/WeaselDeployer.exe" /deploy
timeout /t 1
echo 开始同步用户词库...
start /B /WAIT "" "{install_path}/WeaselDeployer.exe" /sync
echo [结束]
endlocal
::pause
exit