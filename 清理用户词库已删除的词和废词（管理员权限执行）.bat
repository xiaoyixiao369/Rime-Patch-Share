setlocal enabledelayedexpansion

REM 关闭小狼毫算法服务
taskkill /IM:WeaselServer.exe /F
timeout /t 1

REM 删除缓存词库
rmdir /s /q "%USERPROFILE%/AppData/Roaming/Rime/rime_ice.userdb"

REM 进入用户词库目录，开始词库清理(注意，需要先切换到当前驱动器)
:: 设置你的用户词库同步目录
D:
cd "Softwares\OneDrive\RimeSync\Book"

REM 清理中文词库
set "zhDictFile=rime_ice.userdb.txt"
set "zhTempfile=%zhDictFile%.temp"
REM 将不包含 "c=0","c=-" 的行复制到临时文件，并替换现有中文词库文件
findstr /V /C:"c=0" %zhDictFile% | findstr /V /C:"c=-" > %zhTempfile%
del %zhDictFile%
ren %zhTempfile% %zhDictFile%

REM 清理英文词库
set "enDictFile=melt_eng.userdb.txt"
set "enTempfile=%enDictFile%.temp"
REM 将不包含 "c=0","c=-" 的行复制到临时文件，并替换现有英文词库文件
findstr /V /C:"c=0" %enDictFile% | findstr /V /C:"c=-" > %enTempfile%
del %enDictFile%
ren %enTempfile% %enDictFile%


REM 重启小狼毫算法服务，重新部署，同步用户词库
set /p rimeInstallPath=< "%USERPROFILE%/AppData/Roaming/Rime/rimeInstallPath.txt"
start "" /B "%rimeInstallPath%/WeaselServer.exe"
timeout /t 2
start "" /B /WAIT "%rimeInstallPath%/WeaselDeployer.exe" /deploy
start "" /B /WAIT "%rimeInstallPath%/WeaselDeployer.exe" /sync

endlocal

::pause
exit