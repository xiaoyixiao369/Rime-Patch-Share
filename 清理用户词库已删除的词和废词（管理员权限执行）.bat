setlocal enabledelayedexpansion

REM �ر�С�Ǻ��㷨����
taskkill /IM:WeaselServer.exe /F
timeout /t 1

REM ɾ������ʿ�
rmdir /s /q "%USERPROFILE%/AppData/Roaming/Rime/rime_ice.userdb"

REM �����û��ʿ�Ŀ¼����ʼ�ʿ�����(ע�⣬��Ҫ���л�����ǰ������)
:: ��������û��ʿ�ͬ��Ŀ¼
D:
cd "Softwares\OneDrive\RimeSync\Book"

REM �������Ĵʿ�
set "zhDictFile=rime_ice.userdb.txt"
set "zhTempfile=%zhDictFile%.temp"
REM �������� "c=0","c=-" ���и��Ƶ���ʱ�ļ������滻�������Ĵʿ��ļ�
findstr /V /C:"c=0" %zhDictFile% | findstr /V /C:"c=-" > %zhTempfile%
del %zhDictFile%
ren %zhTempfile% %zhDictFile%

REM ����Ӣ�Ĵʿ�
set "enDictFile=melt_eng.userdb.txt"
set "enTempfile=%enDictFile%.temp"
REM �������� "c=0","c=-" ���и��Ƶ���ʱ�ļ������滻����Ӣ�Ĵʿ��ļ�
findstr /V /C:"c=0" %enDictFile% | findstr /V /C:"c=-" > %enTempfile%
del %enDictFile%
ren %enTempfile% %enDictFile%


REM ����С�Ǻ��㷨�������²���ͬ���û��ʿ�
set /p rimeInstallPath=< "%USERPROFILE%/AppData/Roaming/Rime/rimeInstallPath.txt"
start "" /B "%rimeInstallPath%/WeaselServer.exe"
timeout /t 2
start "" /B /WAIT "%rimeInstallPath%/WeaselDeployer.exe" /deploy
start "" /B /WAIT "%rimeInstallPath%/WeaselDeployer.exe" /sync

endlocal

::pause
exit