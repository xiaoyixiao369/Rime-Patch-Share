@echo off
setlocal
:: ------------------------------------------------------------------------
:: ע�⣺
:: 1. Ϊ����������cmd�����в���ʾ�����룬���ļ��ı����ʽ��ҪΪANSI����
:: 2. �豸ͬ�������ļ�installation.yaml��sync_dir��·����ַ��Ҫʹ��\\
:: ------------------------------------------------------------------------
:: ���ܣ�
:: 1. ���ݵ�ǰ�豸�û��ʿ��ļ����豸�ʿ�Ŀ¼�µ�userDictBakDirĿ¼�� 
:: 2. ����ǰ�豸�û��ʿ� 
:: 3. ������ʷ���ݵ��û��ʿ��ļ� 
:: 4. ͬ��Զ�̴���ֿ�
:: 5. ���²���ͬ���û��ʿ�
:: ------------------------------------------------------------------------
:: ������
:: 1. ����/ʹ�ñ��ű�ǰ���������û��ʿ����ݱ��ݣ�ʹ�ù����е��µ����ݶ�ʧ���и���
:: 2. �����ɾ�����û�����ִ�б��ű����ֳ����ˣ����������豸�Ĵʿ����Ƿ������ͬ�Ĵ�
:: 3. �������Ҫ���ݹ��ܣ�������ע�ͻ�ɾ����ش���
:: ------------------------------------------------------------------------
:: ���޸ĵ�����
:: ��ʷ���ݵ��û��ʿ��ļ���������
set "userDictBakStoreDays=30"

:: ------------------------------------------------------------------------
:: �������������޸ģ�ǰ����ʹ����ڡƴ���Ĵ���ֿ�
REM �������ʱ�䣬��ʽΪ��1970-01-01 00:00
for /F "tokens=2 delims==." %%a in ('wmic OS GET LocalDateTime /VALUE') do set "_datetime=%%a"
set "_formatted_date=%_datetime:~0,4%-%_datetime:~4,2%-%_datetime:~6,2%"
set "_formatted_time=%_datetime:~8,2%-%_datetime:~10,2%"
set "curTime=%_formatted_date%_%_formatted_time%"
echo ��ǰ����ʱ�䣺%curTime%

REM �ر�С�Ǻ��㷨����
echo �ر�С�Ǻ��㷨����...
taskkill /IM:WeaselServer.exe /F
timeout 1

REM ��ʼɾ������ʿ�Ŀ¼�е��ļ�
echo ��ʼɾ������ʿ�Ŀ¼�е��ļ�
del /s /q "{user_path}\rime_ice.userdb\*"

REM ��installation.yaml�ļ��н����û��ʿ�ͬ��Ŀ¼��ע�⣺�豸ͬ�������ļ�installation.yaml��sync_dir��·����ַ��Ҫʹ��\\
echo ��ȡ�û�ͬ������...
:: ����Ҫִ�������cd���룬��������ƻ��޷�ִ�гɹ�
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

echo �û��ʿ�ͬ��Ŀ¼��%syncDir%
echo �û��ʿ�ͬ����ʶ���豸����%installationId%
set userDictDir=%syncDir%\\%installationId%
echo ��ǰ�豸ͬ��Ŀ¼��%userDictDir%

REM �������û��ʿ�
set "zhDictFileName=rime_ice.userdb.txt"
set "enDictFileName=melt_eng.userdb.txt"
set "zhDictFile=%userDictDir%\\%zhDictFileName%"
set "enDictFile=%userDictDir%\\%enDictFileName%"
echo �����û��ʿ��ļ��� %zhDictFile%
echo Ӣ���û��ʿ��ļ��� %enDictFile%

:: ------- ����������ʼ������Ҫ���ݹ�����ɾ����С�� -------
REM ���ݵ�ǰ�û��ʿ�
echo ���ݵ�ǰ�û��ʿ�...
set "userDictBakDir=%userDictDir%\\userDictBakDir
set "zhDictBakFile=%userDictBakDir%\\%zhDictFileName%.%curTime%"
set "enDictBakFile=%userDictBakDir%\\%enDictFileName%.%curTime%"
echo �����û��ʿ�Ŀ¼Ϊ�� %userDictBakDir%
:: ��ⱸ��Ŀ¼�Ƿ���ڣ�����������򴴽�
if not exist "%userDictBakDir%" mkdir "%userDictBakDir%"
copy %zhDictFile% %zhDictBakFile%
echo �ѱ��������û��ʿ��ļ����� %zhDictBakFile%
copy %enDictFile% %enDictBakFile%
echo �ѱ���Ӣ���û��ʿ��ļ����� %enDictBakFile%

REM ������ʷ�����ļ�
echo ������ʷ�����ļ�...
for /r "%userDictBakDir%" %%f in (*) do (
    if /i "%%~tf" lss "%date:~0,8% - %userDictBakStoreDays%" del "%%f"
)
:: ------------------------------------- ������������� -----------------------------------

REM �������Ĵʿ�
echo ��ʼ�������Ĵʿ�: %zhDictFile%
set "zhTempfile=%zhDictFile%.temp"
REM �������� "c=0","c=-" ���и��Ƶ���ʱ�ļ������滻�������Ĵʿ��ļ�
findstr /V /C:"c=0" %zhDictFile% | findstr /V /C:"c=-" > %zhTempfile%
move /Y %zhTempfile% %zhDictFile%

REM ����Ӣ�Ĵʿ�
echo ��ʼ����Ӣ�Ĵʿ�...
echo ��ʼ����Ӣ�Ĵʿ�: %enDictFile%
set "enTempfile=%enDictFile%.temp"
REM �������� "c=0","c=-" ���и��Ƶ���ʱ�ļ������滻����Ӣ�Ĵʿ��ļ�
findstr /V /C:"c=0" %enDictFile% | findstr /V /C:"c=-" > %enTempfile%
move /Y  %enTempfile% %enDictFile%

REM ͬ��Զ�̴���ֿ�
echo ͬ��Զ�̴���ֿ�...
start "" /B /WAIT cmd /c "cd {user_path} && git pull"

REM ����С�Ǻ��㷨�������²���ͬ���û��ʿ�
echo ����С�Ǻ��㷨����...
start /B /SEPARATE /HIGH "" "{install_path}/WeaselServer.exe"
timeout /t 1
echo ��ʼ���²���...
start /B /WAIT "" "{install_path}/WeaselDeployer.exe" /deploy
timeout /t 1
echo ��ʼͬ���û��ʿ�...
start /B /WAIT "" "{install_path}/WeaselDeployer.exe" /sync
echo [����]
endlocal
::pause
exit